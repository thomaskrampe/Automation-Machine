# Create required Stores on Storefront Server
#
#    customer: SID Kamenz
#    created:  Thomas Krampe <t.krampe@loginconsultants.de>
#    date:     27.02.2018
#    link:     https://support.citrix.com/article/CTX206009
#

# Import Modules
"C:\Program Files\Citrix\Receiver StoreFront\Scripts\ImportModules.ps1"

# Import comma separated string
$AdditionalStores = $env:SF_Store_List
$AdditionalStores = $AdditionalStores | ConvertFrom-String -Delimiter ","
$SiteID = 1
$AuthenticationVirtualPath = "/Citrix/Authentication"
$authSummary = Get-DSAuthenticationServiceSummary -SiteID $SiteID -VirtualPath $AuthenticationVirtualPath


foreach ($AdditionalStore in $AdditionalStores) {

    # Variables
    $farmName = $AdditionalStore
    $DDC = $env:xd_sf_servers
    $StoreURL = "http://hostname/Citrix/$farmName"
    $ReceiverForWeb = $farmName + "Web"

    Install-DSStoreServiceAndConfigure -authSummary $authSummary -farmName $farmName -farmType XenApp -servers $DDC -servicePort 8080 -siteId $SiteID -transportType HTTP -virtualPath "/Citrix/$farmName" -friendlyName $farmName -loadBalance $False
    Install-DSWebReceiver -FriendlyName $ReceiverForWeb -SiteId $SiteID -StoreUrl $StoreURL -UseHttps $True -VirtualPath /Citrix/$ReceiverForWeb 

    # untested part follows
    # Add-DSGlobalV10Gateway -Address https://nsgateway.domain.com -Id 1 -Logon Domain -Name nsgateway -CallbackUrl https://nsgateway.domain.com -IsDefault $True -RequestTicketTwoSTA $False -SecureTicketAuthorityUrls http://10.25.232.140:8080 -SessionReliability $False
    # Set-DSStoreRemoteAccess -RemoteAccessType StoresOnly -SiteId 1 -VirtualPath /Citrix/Store

    # $gateway = Get-DSGlobalGateway -GatewayId 1
    # Set-DSStoreGateways -SiteId 1 -VirtualPath "/Citrix/Store" -Gateways $gateway

    # Set-DSGlobalInternalBeacon -BeaconAddress https://internal.domain.com -BeaconId 1
    # Add-DSGlobalExternalBeacon -BeaconAddress https://external1.domain.com -BeaconId 2

    }

