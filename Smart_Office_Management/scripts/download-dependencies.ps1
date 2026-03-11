# Download required JARs for Smart Office Management
# Run from project root: .\scripts\download-dependencies.ps1

$libDir = Join-Path $PSScriptRoot "..\src\main\webapp\WEB-INF\lib"
if (-not (Test-Path $libDir)) {
    New-Item -ItemType Directory -Path $libDir -Force | Out-Null
}

$baseUrl = "https://repo1.maven.org/maven2"
$jars = @(
    @{ path = "com/mysql/mysql-connector-j/9.5.0/mysql-connector-j-9.5.0.jar"; name = "mysql-connector-j-9.5.0.jar" },
    @{ path = "org/mindrot/jbcrypt/0.4/jbcrypt-0.4.jar"; name = "jbcrypt-0.4.jar" },
    @{ path = "javax/servlet/jstl/1.2/jstl-1.2.jar"; name = "jstl-1.2.jar" },
    @{ path = "org/apache/poi/poi/5.2.3/poi-5.2.3.jar"; name = "poi-5.2.3.jar" },
    @{ path = "org/apache/poi/poi-ooxml/5.2.3/poi-ooxml-5.2.3.jar"; name = "poi-ooxml-5.2.3.jar" },
    @{ path = "org/apache/poi/poi-ooxml-lite/5.2.3/poi-ooxml-lite-5.2.3.jar"; name = "poi-ooxml-lite-5.2.3.jar" },
    @{ path = "org/apache/commons/commons-collections4/4.4/commons-collections4-4.4.jar"; name = "commons-collections4-4.4.jar" },
    @{ path = "org/apache/commons/commons-compress/1.21/commons-compress-1.21.jar"; name = "commons-compress-1.21.jar" },
    @{ path = "commons-io/commons-io/2.11.0/commons-io-2.11.0.jar"; name = "commons-io-2.11.0.jar" },
    @{ path = "org/apache/xmlbeans/xmlbeans/5.1.1/xmlbeans-5.1.1.jar"; name = "xmlbeans-5.1.1.jar" },
    @{ path = "jakarta/xml/bind/jakarta.xml.bind-api/3.0.1/jakarta.xml.bind-api-3.0.1.jar"; name = "jakarta.xml.bind-api-3.0.1.jar" },
    @{ path = "org/apache/logging/log4j/log4j-api/2.18.0/log4j-api-2.18.0.jar"; name = "log4j-api-2.18.0.jar" }
)

Write-Host "Downloading JARs to $libDir" -ForegroundColor Cyan
foreach ($jar in $jars) {
    $url = "$baseUrl/$($jar.path)"
    $dest = Join-Path $libDir $jar.name
    if (Test-Path $dest) {
        Write-Host "  [SKIP] $($jar.name) (exists)" -ForegroundColor Yellow
    } else {
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
            Write-Host "  [OK] $($jar.name)" -ForegroundColor Green
        } catch {
            Write-Host "  [FAIL] $($jar.name): $_" -ForegroundColor Red
        }
    }
}
Write-Host "Done. Servlet/JSP APIs are provided by Tomcat at runtime." -ForegroundColor Cyan
