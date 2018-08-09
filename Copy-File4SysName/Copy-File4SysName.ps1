$sys=@("SYS1","SYS2","SYS2","SYS2","SYS2")

$sFile="D:\Unyo\Work\対象.xlsx"

if(!(Test-Path -Path $sFile ))
{
    Write-Host "[$sFile]は存在していません"
    exit
}
else
{
    [System.IO.FileInfo]$sf = [System.IO.FileInfo]$sFile
    $sDir       = $sf.DirectoryName
    $sBaseName  = $sf.BaseName
    $sExtension = $sf.Extension
}

foreach( $s in $sys)
{
    $name =   $sBaseName  + "_" + $s + $sExtension
    $newFileName = Join-Path -Path  $sDir -ChildPath $name
    #echo $newFileName
    try
    {
        if((Test-Path -Path $newFileName))
        {
            Move-Item -Path $newFileName
        }
        else
        {
            Copy-Item -Path $sFile -Destination $newFileName
        }
        
        $excel = New-Object -ComObject Excel.Application
        $excel.Visible = $false
        $excel.DisplayAlerts = $false
        
        $wb = $excel.Workbooks.Open($newFileName)
        $ws = $excel.WorkSheets.item("一覧")
        <# create filter
        $xlFilterInPlace = [Microsoft.Office.Interop.Excel.XlFilterAction]::xlFilterInPlace 
        $missing = [Type]::Missing         
        $excel.Selection.AdvancedFilter($xlFilterInPlace, $missing, $missing, $TRUE) 
        #>
        # Specify the range 
        $rng = $ws.Cells.Item(3,7).EntireColumn    #（システム区分）列
        # Select the range
        $rng.select() | Out-Null       

        # Apply the filter. #$rng.AutoFilter(7,"BI5")
        #$excel.selection.AutoFilter(7,$s) 
        $rng.AutoFilter(7,$s) | Out-Null
        
        $ws.Cells.Item(1,1).Activate()| Out-Null
        $wb.Save()
        $wb.Close()
        # Excelを閉じる
        $excel.Quit()
     
        # プロセスを解放する
        
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($rng) > $null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws) > $null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wb) > $null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) > $null
        
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
        [GC]::Collect()
           
    }
    catch [exception]
    {
        Write-Host $error[0]
    }
}