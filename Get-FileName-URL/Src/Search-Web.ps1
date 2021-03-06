. "D:\tools\Ps1Coommon\Common.ps1"

<#
$path = (split-path $MyInvocation.MyCommand.Path) 
#>
$path = "C:\workspace\05.業務共通部品のドキュメント最新調査\01.2nd\GetFiles4URL\"
$loggerPath = $path + "\release\Logger.ps1"; 

. $loggerPath; 
 
$emailFrom = "LoggerTest@domain.com"; 
$emailTo = "<your email address>"; 
$smtpServer = "<fq smtp server name>"; 
 
$logger = Logger; 
$logger.load($path + "\config\log4ps.xml","log.log"); 

<#
$logger.debug("test"); 
$logger.info("test"); 
$logger.warn("test"); 
$logger.error("test"); 
$logger.fatal("test");
#>


# エラートラップの設定
#$ErrorActionPreference = "Stop"　　　# Stop(停止), Inquire ( 問い合わせ ), Continue ( 続行 )




$urlList = New-Object 'System.Collections.Generic.LinkedList[string]'

function IsFile( [String]$path )
{
    #末尾の文字列により判断
    
    if( $path.EndsWith("/"))
    {
        return $false
    }
    else
    {
        return $true
    }
}


function Get-Link4Url 
{
    param([string]$url)
    $_linkList = New-Object System.Collections.ArrayList
    try{   
        [System.Net.HttpWebRequest]$webreq = [System.Net.WebRequest]::Create($url)
        #認証の設定
        $webreq.Credentials = New-Object System.Net.NetworkCredential("zhehuan.ding", "init")
        #HttpWebResponseの取得
        [System.Net.HttpWebResponse]$webres =$webreq.GetResponse()
        #受信して表示
        $st = $webres.GetResponseStream()
        $en_stream = New-Object System.IO.StreamReader ($st, [System.Text.Encoding]::UTF8)
        [String]$data=$en_stream.ReadToEnd()
        
        $html = New-Object -com "HTMLFILE"
        $html.IHTMLDocument2_write($data)
        $html.Close()
     }catch [Exception] {

        $logger.info( "catch error")        
        $logger.info("処理対象URL：[" + $url + "]"); 
        $logger.error($error[0]); 
        
     }finally {
        #Write-Host "finallyの処理です。"
    }
        
   try{     
        foreach( $a in $html.getElementsByTagName("a") )
        {
           if($a -eq $null){ $logger.error("URL:[" + $url + "]には「A」タグは存在していません")}
           else
           {
               $tmp = Get-UrlDecode( $a.pathname )
               if(!$tmp.Equals("../"))
               {
                    $_linkList.Add( $url+$tmp )  | Out-Null
               }
           }
        }
    }catch [Exception] {
    
        $logger.info( "catch error")        
        $logger.info("処理対象URL：[" + $url + "]"); 
        $logger.error($error[0]);  
    }
    return $_linkList
}
 
 #---------------------main-------------------------------------------
 
$df_even = "C:\workspace\05.業務共通部品のドキュメント最新調査\OutPutFiles\even\df_even.txt"
$ff_even = "C:\workspace\05.業務共通部品のドキュメント最新調査\OutPutFiles\even\ff_even.txt"

$df_odd = "C:\workspace\05.業務共通部品のドキュメント最新調査\OutPutFiles\odd\df_odd.txt"
$ff_odd = "C:\workspace\05.業務共通部品のドキュメント最新調査\OutPutFiles\odd\ff_odd.txt"
 
#取得結果
$rtFiles = "C:\workspace\05.業務共通部品のドキュメント最新調査\files.txt"
$rtDirs = "C:\workspace\05.業務共通部品のドキュメント最新調査\dirs.txt"
 
 
 $utxUrl='http://kdz5gl10/svn/Eigyo_Kaikei_system/B10_標準化/04_検討資料/'
 


 $urlList.AddLast( $utxUrl ) | Out-Null
 
 [int]$i=0
 
 while($urlList.count -gt 0 )
{
    $i++
    [String[]]$links =  Get-Link4Url $urlList.First.Value 
    
    foreach($link in $links)
    {
         #重複 と 親  を除く
         if(!($urlList -contains $link) -and ( $link.length -gt ($urlList.First).value.length ))
         {
            #$logger.debug($link); 
            if(IsFile($link))
            {
                $val = "{0:D6}`t`t{1}" -f $i, $link
                Add-Content -Path $rtFiles -Value  $val              
            }
            else
            {
                $urlList.AddLast($link) | Out-Null
            }
         }
    }
    
    # $i even number
    if(($i % 2) -eq 0)
    { Out-File -InputObject $urlList -FilePath $df_even }
    #index odd number
    else{ Out-File -InputObject $urlList -FilePath $df_odd }
    
    $urlList.RemoveFirst()    
}
