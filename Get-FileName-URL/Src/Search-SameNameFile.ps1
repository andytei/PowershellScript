$ErrorActionPrefernce = "Stop"　　　# Stop(停止), Inquire ( 問い合わせ ), Continue ( 続行 )

$path =  "C:\workspace\05.業務共通部品のドキュメント最新調査\01.2nd\GetFiles4URL\"
. "D:\tools\Ps1Coommon\Common.ps1"

$loggerPath = $path + "\release\Logger.ps1"
. $loggerPath;

$emailFrom = "LoggerTest@domain.com"
$emailTo = "<your email address>"
$smtpServer = "<fq smtp server name>"
$logger = Logger
$logger.load($path + "\config\log4ps.xml","log.log")

$tagf  = "C:\workspace\05.業務共通部品のドキュメント最新調査\調査対象整理\1\files.txt" 


#$tags  = New-Object System.Collections.ArrayList
#$tags1 = New-Object System.Collections.ArrayList
<#
$tags  = @{
    FileName   =  @(FilePath);
    .             .          ;
    .             .          ;
    .             .          ; 
}
#>
$tags  = @{}
Get-Content -Path $tagf | % {

    if($_ -match "http.*/(.*)" )
    {
        #$tags.Add( $matches[1],  $_ )
        if( $tags.Keys -contains  $matches[1])
        {
            $tags[$matches[1]].Add($_)                
        }
        else
        {
            $val = New-Object System.Collections.ArrayList            
            $val.Add($_)        
            $tags.Add( $matches[1],  $val )
        }
    }
    else
    {
        $logger.error("特別ファイル：" + $_)
    }
}

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
        #<a>タブの存在するか確認？？？    
        foreach( $a in $html.getElementsByTagName("a") )
        {
            $relativePath = Get-UrlDecode( $a.pathname )            
            if( !$relativePath.Equals("../") ){ $_linkList.Add( $url+$relativePath )  | Out-Null }
        }
    }catch [Exception] {
    
        $logger.info( "catch error")        
        $logger.info("処理対象URL：[" + $url + "]"); 
        $logger.error($error[0]);  
    }finally {
        #Write-Host "finallyの処理です。"
    }

    return $_linkList
}
 
 
function Search-SameNameFile 
{
    param([System.Collections.Generic.LinkedList[string]]$urlList)
    
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
                    #get file name 
                    $fName = 
                    #diff file name 
                
                
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

}

$urlList = New-Object 'System.Collections.Generic.LinkedList[string]'
