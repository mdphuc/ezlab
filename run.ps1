# $jsonBase = @{}
# $list = New-Object System.Collections.Arraylist
# $list.Add("Jo")
# $jsonBase.Add("Detail", $list)
# $jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\test.json" 

$a = "Detail"

$Json = Get-Content .\test.json -Raw | ConvertFrom-Json
$Json.$a += "hola"
$Json | ConvertTo-Json -Depth 10 | Out-File .\test.json

