$ErrorActionPrefernce = "Stop"�@�@�@# Stop(��~), Inquire ( �₢���킹 ), Continue ( ���s )

$path =  "C:\workspace\05.�Ɩ����ʕ��i�̃h�L�������g�ŐV����\01.2nd\GetFiles4URL\"
. "D:\tools\Ps1Coommon\Common.ps1"

$loggerPath = $path + "\release\Logger.ps1"
. $loggerPath;

$emailFrom = "LoggerTest@domain.com"
$emailTo = "<your email address>"
$smtpServer = "<fq smtp server name>"
$logger = Logger
$logger.load($path + "\config\log4ps.xml","log.log")

$tagf  = "C:\workspace\05.�Ɩ����ʕ��i�̃h�L�������g�ŐV����\�����Ώې���\1\files.txt" 


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
        $logger.error("���ʃt�@�C���F" + $_)
    }
}

function IsFile( [String]$path )
{
    #�����̕�����ɂ�蔻�f
    
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
        #�F�؂̐ݒ�
        $webreq.Credentials = New-Object System.Net.NetworkCredential("zhehuan.ding", "init")
        #HttpWebResponse�̎擾
        [System.Net.HttpWebResponse]$webres =$webreq.GetResponse()
        #��M���ĕ\��
        $st = $webres.GetResponseStream()
        $en_stream = New-Object System.IO.StreamReader ($st, [System.Text.Encoding]::UTF8)
        [String]$data=$en_stream.ReadToEnd()
        
        $html = New-Object -com "HTMLFILE"
        $html.IHTMLDocument2_write($data)
        $html.Close()
        #<a>�^�u�̑��݂��邩�m�F�H�H�H    
        foreach( $a in $html.getElementsByTagName("a") )
        {
            $relativePath = Get-UrlDecode( $a.pathname )            
            if( !$relativePath.Equals("../") ){ $_linkList.Add( $url+$relativePath )  | Out-Null }
        }
    }catch [Exception] {
    
        $logger.info( "catch error")        
        $logger.info("�����Ώ�URL�F[" + $url + "]"); 
        $logger.error($error[0]);  
    }finally {
        #Write-Host "finally�̏����ł��B"
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
             #�d�� �� �e  ������
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
