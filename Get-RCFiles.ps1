$MAXPATH = 200
$fileextensions='.pdf','.doc','.xls','.ppt'

$baseurl = "https://financialservices.royalcommission.gov.au"
$webpage = "https://financialservices.royalcommission.gov.au/public-hearings/Pages/Additional-exhibits-round-5.aspx"

#Ensure this folder exists!
$downloadlocation = "C:\TEMP\rc\Exhibits\Round 5\Day 1\"

$LogDate = Get-Date -UFormat "%Y%m%d"
$LogFile = $downloadlocation + 'LogFile-' + $LogDate + '.txt'


foreach ($fileextension in $fileextensions) {


    #Create an Object containing every hyperlink on a specific Web Page
    $myLinksObject = (Invoke-WebRequest -Uri $webpage).Links

    #Create another Object, since we're only interested in hyperlinks containing a specific File Extension to Download
    $myDownloadLinksObject = $myLinksObject | where-object {($_.href -like "*$fileextension")}

    #For each hyperlink, save the File using the Description as its FileName.
    #Trim invalid characters present in the Description: Newlines, carriage returns, colons, slashes, quotes and pipes
    #Trim the FileName if it exceeds $MAXPATH characters
    foreach ($link in $myDownloadLinksObject) {
        $filenametemp = $link.outerText
        $filenametemp = $filenametemp -replace "`n|`r|:|/|`"|\|"
        
        if ($filenametemp.length -gt $MAXPATH) {
            $filenametemp = $filenametemp.substring(0, $MAXPATH)
        }

        $filename = $downloadlocation + $filenametemp + "$fileextension"
        
        $url = $baseurl + $link.href

        if(![System.IO.File]::Exists($filename)){
            #File with path $filename doesn't exist, lets download it
            (New-Object System.Net.WebClient).DownloadFile("$url", "$filename")    
            write-host "URL: $url"
            write-host "Downloaded to: $filename"
            write-host "`n"
            
            #Log it
            $timestamp = Get-Date -format "yyyyMMddhhmmss"
            $value = $timestamp + ": URL: $url has been downloaded to: $filename"
            add-content -path $LogFile -value $value  
        }
    }

    $timestamp = Get-Date -format "yyyyMMddhhmmss"
    $value = $timestamp + ": The Web Page $webpage contains " + $myDownloadLinksObject.count + " hyperlinks with file extension $fileextension"
    add-content -path $LogFile -value $value


}






