function New-RoleAssignment {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $ObjectId,

        [Parameter(Mandatory = $true)]
        [string]
        $Role
    )

    Invoke-Expression -Command "az role assignment create --assignee $ObjectId --role '$Role'" | Out-Null
}
