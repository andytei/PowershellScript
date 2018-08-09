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
$tagf1 = "C:\workspace\05.業務共通部品のドキュメント最新調査\__files.txt"

#$tags  = New-Object System.Collections.ArrayList
#$tags1 = New-Object System.Collections.ArrayList
<#
$tags  = @{
    Name = ""
    URL  = ""
    Same = @()    
}

$tags1 = @{ 
    Name = ""
    URL  = ""
}
#>

$tags  = @{}
$tags1 = @{}

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

Get-Content -Path $tagf1 | % {

    if($_ -match "http.*/(.*)" )
    {
        if( $tags1.Keys -contains  $matches[1])
        {
            $tags1[$matches[1]].Add($_)                
        }
        else
        {
            $val = New-Object System.Collections.ArrayList            
            $val.Add($_)        
            $tags1.Add( $matches[1],  $val )
        }
        
    }
    else
    {
        $logger.error("特別ファイル：" + $_)
    }
}


foreach($sk in $tags.keys)
{
    foreach($dk in $tags1.keys)
    {
        if($sk-eq $dk)
        {
            echo $s
        }
    }
}