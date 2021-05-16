// TODO: take a parameter
$dscName = "WebServer"

# compile the dsc modules
Publish-AzVMDscConfiguration .\$dscName.ps1 -OutputArchivePath .\$dscName.zip -Force

#Connect-AzAccount -Subscription 'Production'

$storageAccountName = '<storageaccount>'
$resourceGroupName = '<resource group name>'
$containerName = 'dsc'
$location = '<location>'

# get the dsc storage account
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
    Write-Host "New resource group '$resourceGroupName' created"
}

$storageAccount = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName  -ErrorAction SilentlyContinue
if (-not $storageAccount) {
    $storageAccount = New-AzStorageAccount -Name  $storageAccountName -ResourceGroupName $resourceGroupName -SkuName 'Standard_LRS' -Location $location -ErrorAction SilentlyContinue
    Write-Host "New storage account '$storageAccountName' created"
}

# get the dsc storage container
$container = ($storageAccount | Get-AzStorageContainer -Name $containerName -ErrorAction SilentlyContinue)
if (-not $container) {
    $storageAccount | New-AzStorageContainer -Name $containerName -ErrorAction SilentlyContinue
    $container = $storageAccount | Get-AzStorageContainer -Name  $containerName
    Write-Host "New container '$containerName' created"
}

# upload the dsc file to azure
$container | Set-AzStorageBlobContent -File .\$dscName.zip -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "Uploaded: $($container.CloudBlobContainer.Uri.AbsoluteUri)"
