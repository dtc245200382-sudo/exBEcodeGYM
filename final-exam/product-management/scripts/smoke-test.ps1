param([string]$BaseUrl = 'http://localhost:8080/product-management')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
$BaseUrl = $BaseUrl.TrimEnd('/')
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$handler.CookieContainer = [System.Net.CookieContainer]::new()
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(20)
$checks = [Collections.Generic.List[string]]::new()
$createdIds = [Collections.Generic.List[int]]::new()
$csrf = ''

function Send-Request([string]$Method, [string]$Path, [hashtable]$Form = @{}) {
    $message = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($Method), "$BaseUrl$Path")
    if ($Method -eq 'POST') {
        $fields = [Collections.Generic.Dictionary[string,string]]::new()
        foreach ($key in $Form.Keys) { $fields.Add($key, [string]$Form[$key]) }
        $message.Content = [System.Net.Http.FormUrlEncodedContent]::new($fields)
    }
    try {
        $response = $client.SendAsync($message).GetAwaiter().GetResult()
        try {
            [pscustomobject]@{
                Status = [int]$response.StatusCode
                Body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
                Location = [string]$response.Headers.Location
            }
        } finally { $response.Dispose() }
    } finally { $message.Dispose() }
}

function Check([bool]$Condition, [string]$Description) {
    if (-not $Condition) { throw "FAIL: $Description" }
    $line = "PASS: $Description"
    $checks.Add($line)
    Write-Output $line
}

function Find-ProductId([string]$Body, [string]$Name) {
    foreach ($row in [regex]::Matches($Body, '(?s)<tr>.*?</tr>')) {
        if ($row.Value.Contains($Name)) {
            $match = [regex]::Match($row.Value, 'action=edit&amp;id=(\d+)')
            if ($match.Success) { return [int]$match.Groups[1].Value }
        }
    }
    throw "Product not found: $Name"
}

try {
    $list = Send-Request GET '/products'
    Check ($list.Status -eq 200 -and $list.Body.Contains('Danh sách sản phẩm')) 'List page loads through Servlet and JSP'
    $root = Send-Request GET '/'
    Check ($root.Status -eq 200 -and $root.Body.Contains('Danh sách sản phẩm')) 'Application root uses the welcome servlet'
    $css = Send-Request GET '/assets/styles.css'
    Check ($css.Status -eq 200 -and $css.Body.Contains('@media')) 'Stylesheet and responsive rules are available'
    $form = Send-Request GET '/products?action=create'
    $csrfMatch = [regex]::Match($form.Body, 'name="csrf" value="([^"]+)"')
    Check ($form.Status -eq 200 -and $csrfMatch.Success) 'Add form includes a session token'
    $csrf = $csrfMatch.Groups[1].Value

    $forbidden = Send-Request POST '/products' @{action='create'; name='Must not be saved'; price='1'; quantity='1'}
    Check ($forbidden.Status -eq 403) 'Missing CSRF token is rejected'
    $forbidden = Send-Request POST '/products' @{action='create'; csrf='wrong'; name='Must not be saved'; price='1'; quantity='1'}
    Check ($forbidden.Status -eq 403) 'Invalid CSRF token is rejected'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=''; price='-1'; quantity='1.5'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains('Tên sản phẩm phải') -and $invalid.Body.Contains('Giá phải') -and $invalid.Body.Contains('Số lượng phải')) 'Server validates all three input fields'
    $draft = 'Giữ lại nội dung đã nhập'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$draft; price='1.001'; quantity='2'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains($draft)) 'Invalid decimal price does not discard the typed name'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='A'; price='10000000000000'; quantity='2147483648'}
    Check ($invalid.Status -eq 400) 'Price and quantity overflow are rejected'

    $suffix = [Guid]::NewGuid().ToString('N').Substring(0, 10)
    $originalName = "Sản phẩm thử nghiệm $suffix"
    $created = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$originalName; price='12345.67'; quantity='7'}
    Check ($created.Status -eq 303 -and $created.Location.EndsWith('/products')) 'Create uses Post/Redirect/Get'
    $list = Send-Request GET '/products'
    $productId = Find-ProductId $list.Body $originalName
    $createdIds.Add($productId)
    Check ($list.Body.Contains('12345.67') -and $list.Body.Contains('Đã thêm sản phẩm.')) 'Created product and success message appear in the list'
    $refreshed = Send-Request GET '/products'
    Check (([regex]::Matches($refreshed.Body, [regex]::Escape($originalName))).Count -eq 1) 'Refreshing the list does not create another product'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Status -eq 200 -and $edit.Body.Contains($originalName) -and $edit.Body.Contains('value="12345.67"') -and $edit.Body.Contains('value="7"')) 'Edit form is prefilled from MySQL'

    $changedName = "Đã sửa $suffix <script>alert(1)</script> ' OR 1=1 --"
    $escapedName = $changedName.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;').Replace("'",'&#39;')
    $updated = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; quantity='0'}
    Check ($updated.Status -eq 303) 'Updating a product succeeds'
    $list = Send-Request GET '/products'
    Check ($list.Body.Contains($escapedName) -and $list.Body.Contains('99.10')) 'Unicode, apostrophes and decimal money survive the JDBC round trip'
    Check (-not $list.Body.Contains('<script>alert(1)</script>')) 'Product name is escaped in HTML'
    $again = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; quantity='0'}
    Check ($again.Status -eq 303) 'Saving unchanged values is accepted'
    $invalid = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=''; price='-9'; quantity='-1'}
    Check ($invalid.Status -eq 400) 'Invalid update is rejected'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Body.Contains($escapedName) -and $edit.Body.Contains('value="99.10"')) 'Invalid update leaves the stored product unchanged'

    $confirmation = Send-Request GET "/products?action=confirm-delete&id=$productId"
    Check ($confirmation.Status -eq 200 -and $confirmation.Body.Contains('Xác nhận xoá') -and $confirmation.Body.Contains('name="confirmed" value="yes"')) 'Delete opens a confirmation page'
    $list = Send-Request GET '/products'
    Check ($list.Body.Contains($escapedName)) 'Opening or cancelling confirmation does not delete the product'
    $unconfirmed = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId}
    Check ($unconfirmed.Status -eq 400) 'Deletion without explicit confirmation is rejected'
    $getDelete = Send-Request GET "/products?action=delete&id=$productId"
    Check ($getDelete.Status -eq 400) 'A GET request cannot delete data'
    $deleted = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($deleted.Status -eq 303) 'Confirmed deletion succeeds'
    $list = Send-Request GET '/products'
    Check (-not $list.Body.Contains($escapedName)) 'Deleted product disappears from the list'
    $missing = Send-Request GET "/products?action=edit&id=$productId"
    Check ($missing.Status -eq 404) 'A deleted product cannot be edited'
    $stale = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name='Stale'; price='1'; quantity='1'}
    Check ($stale.Status -eq 404) 'Submitting a stale edit does not recreate the product'
    $missing = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($missing.Status -eq 404) 'Repeated delete reports a missing product'
    $badId = Send-Request GET '/products?action=edit&id=not-an-id'
    Check ($badId.Status -eq 400) 'Malformed product ID is rejected'
    $privateView = Send-Request GET '/WEB-INF/views/list.jsp'
    Check ($privateView.Status -eq 404) 'JSP views are protected behind WEB-INF'
    $newSession = [System.Net.Http.HttpClient]::new()
    try {
        $freshList = $newSession.GetStringAsync("$BaseUrl/products").GetAwaiter().GetResult()
        Check ($freshList.Contains('Danh sách sản phẩm')) 'Another session reads the same database-backed list'
    } finally { $newSession.Dispose() }
    Write-Output "RESULT: $($checks.Count) HTTP checks passed"
} finally {
    # Chỉ dọn bản ghi do lượt kiểm thử này tạo, không xoá dữ liệu mẫu hay sản phẩm khác.
    foreach ($createdId in $createdIds) {
        try { $null = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$createdId; confirmed='yes'} } catch { }
    }
    $client.Dispose()
}
