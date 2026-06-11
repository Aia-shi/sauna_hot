# Uruchamia prosty serwer HTTP, żeby modele .glb mogły się załadować.
# Użycie (najłatwiej): dwuklik na start-server.bat
# Albo w terminalu: powershell -ExecutionPolicy Bypass -File .\start-server.ps1

$port = 5500
$root = $PSScriptRoot

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "Serwer dziala: http://localhost:$port/base.html" -ForegroundColor Green
Write-Host "Nacisnij Ctrl+C aby zatrzymac." -ForegroundColor Yellow

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".glb"  = "model/gltf-binary"
  ".gltf" = "model/gltf+json"
  ".js"   = "application/javascript"
  ".css"  = "text/css"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.LocalPath.TrimStart("/")
    if ([string]::IsNullOrWhiteSpace($path)) { $path = "base.html" }

    $file = Join-Path $root ($path -replace "/", [IO.Path]::DirectorySeparatorChar)

    if (Test-Path $file -PathType Leaf) {
      $ext = [IO.Path]::GetExtension($file).ToLower()
      $bytes = [IO.File]::ReadAllBytes($file)
      $response.StatusCode = 200
      $response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $response.StatusCode = 404
      $msg = [Text.Encoding]::UTF8.GetBytes("404 - nie znaleziono: $path")
      $response.ContentType = "text/plain; charset=utf-8"
      $response.ContentLength64 = $msg.Length
      $response.OutputStream.Write($msg, 0, $msg.Length)
    }

    $response.Close()
  }
} finally {
  $listener.Stop()
}
