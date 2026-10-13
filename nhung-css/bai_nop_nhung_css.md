# Bài tập: Nhúng CSS vào trang HTML

Một file nộp chung chứa đầy đủ mã nguồn ba cách nhúng CSS. Các file chạy thử nằm cùng thư mục. Mỗi trang có một tiêu đề màu xanh lá và một đoạn văn màu xanh dương theo ảnh mẫu.

## Phần 1: Inline CSS

Đặt CSS trực tiếp trong thuộc tính style của từng phần tử.

File: [inline.html](./inline.html)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inline CSS</title>
</head>
<body>
    <h1 style="color: green;">This is heading 1</h1>
    <p style="color: blue;">This is an ordinary paragraph. Notice that this text is blue. The default text color for a page is defined in the body selector.</p>
</body>
</html>

```

## Phần 2: Internal CSS

Khai báo CSS trong thẻ style thuộc head. Đoạn văn kế thừa màu từ body.

File: [internal.html](./internal.html)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Internal CSS</title>
    <style>
        body {
            color: blue;
        }

        h1 {
            color: green;
        }
    </style>
</head>
<body>
    <h1>This is heading 1</h1>
    <p>This is an ordinary paragraph. Notice that this text is blue. The default text color for a page is defined in the body selector.</p>
</body>
</html>

```

## Phần 3: External CSS — HTML

Liên kết file styles.css bằng thẻ link. Giữ hai file cùng thư mục khi mở trong trình duyệt.

File: [external.html](./external.html)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>External CSS</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>This is heading 1</h1>
    <p>This is an ordinary paragraph. Notice that this text is blue. The default text color for a page is defined in the body selector.</p>
</body>
</html>

```

## Phần 3: External CSS — stylesheet

CSS nằm trong file riêng, không nhúng vào HTML.

File: [styles.css](./styles.css)

```css
body {
    color: blue;
}

h1 {
    color: green;
}

```
