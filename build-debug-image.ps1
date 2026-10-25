param(
    [Parameter(Mandatory=$true)]
    [string]$IMAGE_NAME,

    [ValidatePattern('^[0-9]+\.[0-9]+(\.[0-9]+)?$')]
    [string]$Version = 'latest'
)

docker build -t "${IMAGE_NAME}:${Version}" -f .\ci\Dockerfile .
