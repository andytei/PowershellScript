Add-Type -Assembly "Microsoft.Office.Interop.Outlook"
$scriptDir  = Split-Path $MyInvocation.MyCommand.Path -Parent
$scriptHome = Split-Path -Parent $ScriptDir
$dataSource = Join-Path -Path ($scriptHome + "\Template")  -ChildPath  "mailDB.csv" 

$from = "name@form.com"
$CSV_DATA = Get-Content -Path $dataSource -Encoding String | ConvertFrom-Csv

foreach( $sys in $CSV_DATA)
{
    if($sys.SendSwitch.Equals("T"))
    {
        $saveFile   = Join-Path -Path ($scriptHome + "\CreatedMail")  -ChildPath  ($sys.Subject + ".msg")
        $Outlook = New-Object -ComObject Outlook.Application
        #templateでメールを作成
        #$mail = $Outlook.CreateItemFromTemplate($sys.MailTemplate)
        #空メールを作成
        $mail = $Outlook.CreateItem(0)
        $mail.To = $sys.DestinationAddress
        $mail.CC = $sys.CC
        $mail.Subject = $sys.Subject
        $sys.Attachments -split ";" | % {$mail.Attachments.Add( $_ ) | Out-Null }
        $sr = New-Object System.IO.StreamReader($sys.MailTemplate, [System.Text.Encoding]::GetEncoding("sjis"))
        $body = $sr.ReadToEnd()
        $sr.close()
        $sr = $null
        $body= $body -replace ("{DestinationName}"),  $sys.DestinationName 
        $body= $body -replace ("{ResponseDeadline}"), $sys.ResponseDeadline
        $mail.body = $body
        #$mail.display()
        $mail.SaveAs($saveFile)
    }
}
