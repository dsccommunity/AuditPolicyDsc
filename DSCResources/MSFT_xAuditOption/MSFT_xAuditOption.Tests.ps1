cls

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")

Import-Module "$PSScriptRoot\$sut" -Force

# set the audit option test strings to Mock
$OptionName  = 'CrashOnAuditFail'
$OptionState = 'Disabled'
$OptionStateSwap = @{'Disabled'='Enabled';'Enabled'='Disabled'}


Describe "Get-TargetResource" {

    Context "Unit testing" {
     
        # mock call to the helper module to isolate Get-TargetResource
        Mock Get-AuditOption { return $OptionState } -ModuleName MSFT_xAuditOption

        $Get = Get-TargetResource -Name $OptionName

        It "Return object is a hashtable" {
            $isHashtable = $Get.GetType().Name -eq 'hashtable'
        
            $isHashtable | Should Be $true
        }

        It " that has a 'Name' key" {
            $ContainsNameKey = $get.ContainsKey('Name')

            $ContainsNameKey | Should Be $true
        }
    
        It "  with a value of '$OptionName'" {
            $RetrievedOptionName = $Get.Name 
            $RetrievedOptionName | Should Be $OptionName
        }

        It " that has a 'Value' key" {
            $ContainsValueKey = $get.ContainsKey('Value')
            $ContainsValueKey | Should Be $true
        }
    
        It "  with a value of '$OptionState'" {
            $Get.Value | Should Be $OptionState
        }
    }
}

Describe "Set-TargetResource" {
    
    Context "Unit Testing" {

       # mock call to the helper module to isolate Set-TargetResource
        Mock Set-AuditOption {return } -ModuleName MSFT_xAuditOption
        
        $Set = Set-TargetResource -Name $OptionName -Value $OptionState

        It " returns no object" {
        
            $Set | Should BeNullOrEmpty
        }
    }
}



Describe "Test-TargetResource unit tests" {

    Context "Unit Testing" {

        # mock call to the helper module to isolate Test-TargetResource
        Mock Get-AuditOption { return $OptionState } -ModuleName MSFT_xAuditOption

        $Test = Test-TargetResource -Name $OptionName -Value $OptionState

        It "Return object is a Boolean" {
            $IsBool = $Test.GetType().Name -eq "Boolean"

            $IsBool | Should Be $true
        }

        It " that is true when matching" {
            $ValueMatches = $test
        
            $ValueMatches | Should Be $true
        }

        It " that is false when not matching" {
            $ValueNotMatches = Test-TargetResource -Name $OptionName -Value $OptionStateSwap[$OptionState]
        
            $ValueNotMatches | Should Be $false
        }
    }
}