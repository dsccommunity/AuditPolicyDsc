cls

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")

Import-Module "$here\$sut" -Force

# the audit option to use in the tests
$Subcategory   = 'logon'
$AuditFlag     = 'Failure'
$MockAuditFlags = 'Success','Failure','SuccessandFailure','NoAuditing'
$AuditFlagSwap = @{'Failure'='Success';'Success'='Failure'}

Describe -Tags Unit, Get "Get-TargetResource - Unit tests" {
    
    Context "Return object " {
        
        # mock call to the helper module to isolate Get-TargetResource
        Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlag} } -ModuleName MSFT_xAuditCategory

        $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

            It " is a hashtable that has the following keys:" {
                $isHashtable = $Get.GetType().Name -eq 'hashtable'

                $isHashtable | Should Be $true
            }
    
            It "  Subcategory" {
                $ContainsSubcategoryKey = $Get.ContainsKey('Subcategory') 
        
                $ContainsSubcategoryKey | Should Be $true
            }

            It "  AuditFlag" {
                $ContainsAuditFlagKey = $Get.ContainsKey('AuditFlag') 
        
                $ContainsAuditFlagKey | Should Be $true
            }

            It "  Ensure" {
                $ContainsEnsureKey = $Get.ContainsKey('Ensure') 
        
                $ContainsEnsureKey| Should Be $true
            }
    }

    Context "Submit '$AuditFlag' and return '$AuditFlag'" {

        # mock call to the helper module to isolate Get-TargetResource
        Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlag} } -ModuleName MSFT_xAuditCategory

        $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

        It " 'Subcategory' = '$Subcategory'" {
            $RetrievedSubcategory =  $Get.Subcategory 
        
            $RetrievedSubcategory | Should Be $Subcategory
        }
            
        It " 'AuditFlag' = '$AuditFlag'" {
            $RetrievedAuditFlag = $Get.AuditFlag 
        
            $RetrievedAuditFlag | Should Match $AuditFlag
        }

        It " 'Ensure' = 'Present'" {
            $RetrievedEnsure = $Get.Ensure 
        
            $RetrievedEnsure | Should Be 'Present'
        }
    }

    Context "Submit '$AuditFlag' and return '$($AuditFlagSwap[$AuditFlag])'" {
    
        # mock call to the helper module to isolate Get-TargetResource
        Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'=$AuditFlagSwap[$AuditFlag]} } -ModuleName MSFT_xAuditCategory

        $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

        It " 'Subcategory' = '$Subcategory'" {
            $RetrievedSubcategory =  $Get.Subcategory 
        
            $RetrievedSubcategory | Should Be $Subcategory
        }
            
        It " 'AuditFlag' != '$AuditFlag'" {
            $RetrievedAuditFlag = $Get.AuditFlag 
        
            $RetrievedAuditFlag | Should Not Match $AuditFlag
        }

        It " 'Ensure' = 'Absent'" {
            $RetrievedEnsure = $Get.Ensure 
        
            $RetrievedEnsure | Should Be 'Absent'
        }
    }

    Context "Submit '$AuditFlag' and return 'NoAuditing'" {

        Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'='NoAuditing'} } -ModuleName MSFT_xAuditCategory

        $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag
    
        It " 'Subcategory' = '$Subcategory'" {
            $RetrievedSubcategory =  $Get.Subcategory 
        
            $RetrievedSubcategory | Should Be $Subcategory
        }

        It " 'AuditFlag' != '$AuditFlag'" {
            $RetrievedAuditFlag = $Get.AuditFlag 
        
            $RetrievedAuditFlag | Should Not Match $AuditFlag
        }


        It " 'Ensure' = 'Absent'" {
            $RetrievedEnsure = $Get.Ensure 
        
            $RetrievedEnsure | Should Be 'Absent'
        }

    }

    Context "Submit '$AuditFlag' and return 'SuccessandFailure'" {

        Mock Get-AuditCategory { return @{'Name'=$Subcategory;'AuditFlag'='SuccessandFailure'} } -ModuleName MSFT_xAuditCategory

        $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag
    
        It " 'Subcategory' = '$Subcategory'" {
            $RetrievedSubcategory =  $Get.Subcategory 
        
            $RetrievedSubcategory | Should Be $Subcategory
        }

        It " 'AuditFlag' = '$AuditFlag'" {
            $RetrievedAuditFlag = $Get.AuditFlag 
        
            $RetrievedAuditFlag | Should Be $AuditFlag
        }


        It " 'Ensure' = 'Present'" {
            $RetrievedEnsure = $Get.Ensure 
        
            $RetrievedEnsure | Should Be 'Present'
        }

    }
}


Describe -Tags Integration, Get "Get-TargetResource - Integration tests" {

    $Get = Get-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

    It "  'Subcategory' key has a value of '$Subcategory'" {
            $RetrievedSubcategory =  $Get.Subcategory 
        
            $RetrievedSubcategory | Should Be $Subcategory
    }

    It "  'AuditFlag' has a value " {
            $RetrievedAuditFlag = $Get.AuditFlag 
        
            $RetrievedAuditFlag | Should Match "(Success|Failure|NoAuditing)"
    }

    Context "Validate support function(s) in helper module" {

        $Function = ((Get-Module -All 'Helper').ExportedCommands['Get-AuditCategory'])

        It " Found function 'Get-AuditCategory'" {
            $FunctionName = $Function.Name
        
            $FunctionName | Should Be 'Get-AuditCategory'
        }

        It " Found parameter 'Subcategory'" {
            $Subcategory = $Function.Parameters['Subcategory'].name
        
            $Subcategory | Should Be 'Subcategory'
        }
    }
}



Describe -Tags Unit, Set "Set-TargetResource - Unit tests" {

}

Describe -Tags Integration, Set "Set-TargetResource - Integration tests" {

}

Describe -Tags Unit, Test "Test-TargetResource - Unit tests" {
    
    $Test = Test-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag
    
    It "Returns a boolean" {
        $isBool = $Test.GetType().Name -eq 'Boolean'
        $isBool | Should Be $true
    }
}

Describe -Tags Integration, Test "Test-TargetResource - Integration tests" {

}