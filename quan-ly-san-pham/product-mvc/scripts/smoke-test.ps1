param([string]$BaseUrl = 'http://localhost:8080/product-mvc')
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
            [pscustomobject]@{ Status = [int]$response.StatusCode; Body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult(); Location = [string]$response.Headers.Location }
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
    foreach ($row in [regex]::Matches($Body, '(?s)<tr data-product-id="(\d+)">.*?</tr>')) {
        if ($row.Value.Contains($Name)) { return [int]$row.Groups[1].Value }
    }
    throw "Product not found: $Name"
}

try {
    $list = Send-Request GET '/products'
    Check ($list.Status -eq 200 -and $list.Body.Contains('Bàn phím cơ') -and $list.Body.Contains('Nhà sản xuất')) 'List displays seeded products and all required attributes'
    $root = Send-Request GET '/'
    Check ($root.Status -eq 200 -and $root.Body.Contains('Danh sách sản phẩm')) 'Application root opens the list servlet'
    $css = Send-Request GET '/assets/styles.css'
    Check ($css.Status -eq 200 -and $css.Body.Contains('@media')) 'Responsive stylesheet loads'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString(' BÀN PHÍM '))
    Check ($search.Status -eq 200 -and ([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 2) 'Partial Vietnamese name search ignores case and surrounding spaces'
    $search = Send-Request GET '/products?action=search&keyword=not-found-unique-xyz'
    Check ($search.Status -eq 200 -and $search.Body.Contains('Không có sản phẩm phù hợp.')) 'A search with no matches displays an empty state'
    $form = Send-Request GET '/products?action=create'
    $csrfMatch = [regex]::Match($form.Body, 'name="csrf" value="([^"]+)"')
    Check ($form.Status -eq 200 -and $csrfMatch.Success -and $form.Body.Contains('name="manufacturer"')) 'Create form loads with all fields and a CSRF token'
    $csrf = $csrfMatch.Groups[1].Value
    $forbidden = Send-Request POST '/products' @{action='create'; name='Rejected'; price='1'; manufacturer='A'}
    Check ($forbidden.Status -eq 403) 'A mutation without a CSRF token is rejected'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=''; price='1'; manufacturer='A'}
    Check ($invalid.Status -eq 400) 'Blank product names are rejected on the server'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='Tên chưa lưu'; price='1.001'; description='Nội dung giữ lại'; manufacturer='A'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains('Tên chưa lưu') -and $invalid.Body.Contains('Nội dung giữ lại')) 'Invalid prices keep the original form data'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='A'; price='1'; manufacturer=''}
    Check ($invalid.Status -eq 400) 'Blank manufacturers are rejected'

    $suffix = [Guid]::NewGuid().ToString('N').Substring(0, 10)
    $originalName = "Sản phẩm thử $suffix"
    $description = "Mô tả nhiều dòng`nNội dung chi tiết $suffix"
    $created = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$originalName; price='12345.67'; description=$description; manufacturer='Hãng Việt'}
    Check ($created.Status -eq 303 -and $created.Location.EndsWith('/products')) 'Creating a product redirects to the list'
    $list = Send-Request GET '/products'
    $productId = Find-ProductId $list.Body $originalName
    $createdIds.Add($productId)
    Check ($list.Body.Contains('12345.67') -and $list.Body.Contains('Đã thêm sản phẩm.')) 'New product, decimal price and success message are visible'
    $refresh = Send-Request GET '/products'
    Check (([regex]::Matches($refresh.Body, [regex]::Escape($originalName))).Count -eq 1) 'Refreshing does not duplicate the created product'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Status -eq 200 -and $view.Body.Contains($originalName) -and $view.Body.Contains($description) -and $view.Body.Contains('Hãng Việt')) 'Detail page displays name, price, description and manufacturer'
    $freshClient = [System.Net.Http.HttpClient]::new()
    try {
        $shared = $freshClient.GetStringAsync("$BaseUrl/products?action=view&id=$productId").GetAwaiter().GetResult()
        Check ($shared.Contains($originalName)) 'Another session sees the same static Map data'
    } finally { $freshClient.Dispose() }
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Status -eq 200 -and $edit.Body.Contains($originalName) -and $edit.Body.Contains('value="12345.67"') -and $edit.Body.Contains('Hãng Việt')) 'Edit form is prefilled with the saved product'

    $changedName = "Đã sửa $suffix <script>alert(1)</script>"
    $changedDescription = "Mô tả <img src=x onerror=alert(1)> $suffix"
    $updated = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; description=$changedDescription; manufacturer='Hãng mới'}
    Check ($updated.Status -eq 303) 'Editing the product succeeds'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Body.Contains('99.10') -and $view.Body.Contains('Hãng mới')) 'Updated price and manufacturer are stored'
    Check ($view.Body.Contains('&lt;script&gt;') -and $view.Body.Contains('&lt;img') -and -not $view.Body.Contains('<script>') -and -not $view.Body.Contains('<img src=x')) 'JSTL escapes user content on the detail page'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Body.Contains('&lt;script&gt;') -and -not $edit.Body.Contains('<script>')) 'Edit form also escapes the existing user content'
    $invalid = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name='A'; price='-9'; description=''; manufacturer='B'}
    Check ($invalid.Status -eq 400) 'Negative price updates are rejected'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Body.Contains('99.10') -and $view.Body.Contains('Hãng mới')) 'Rejected edits leave the stored product unchanged'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString("ĐÃ SỬA $suffix"))
    Check (([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 1) 'Searching finds the renamed product'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString('Mô tả <img'))
    Check (([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 0) 'Search matches names rather than descriptions'

    $confirmation = Send-Request GET "/products?action=delete&id=$productId"
    Check ($confirmation.Status -eq 200 -and $confirmation.Body.Contains('Xác nhận xoá') -and $confirmation.Body.Contains('name="confirmed" value="yes"')) 'Delete opens a confirmation page'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Status -eq 200) 'Opening or cancelling the delete page leaves the product intact'
    $unconfirmed = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId}
    Check ($unconfirmed.Status -eq 400) 'Unconfirmed deletion is rejected'
    $deleted = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($deleted.Status -eq 303) 'Confirmed deletion succeeds'
    $missing = Send-Request GET "/products?action=view&id=$productId"
    Check ($missing.Status -eq 404) 'Deleted products no longer have a detail page'
    $stale = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name='Stale'; price='1'; manufacturer='A'}
    Check ($stale.Status -eq 404) 'A stale edit cannot recreate a deleted product'
    $badId = Send-Request GET '/products?action=view&id=abc'
    Check ($badId.Status -eq 400) 'Malformed IDs receive an error page'
    $private = Send-Request GET '/WEB-INF/views/list.jsp'
    Check ($private.Status -eq 404) 'JSP templates cannot be accessed directly'
    Write-Output "RESULT: $($checks.Count) HTTP checks passed"
} finally {
    foreach ($createdId in $createdIds) {
        try { $null = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$createdId; confirmed='yes'} } catch { }
    }
    $client.Dispose()
}
