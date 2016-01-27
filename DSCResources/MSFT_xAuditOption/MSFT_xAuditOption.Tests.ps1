$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")

Import-Module "$PSScriptRoot\$sut" -Force

# set the audit option test strings to Mock
$optionName  = 'CrashOnAuditFail'
$optionState = 'Disabled'
$optionStateSwap = @{'Disabled'='Enabled';'Enabled'='Disabled'}


Describe "Get-TargetResource" {

    Context "Unit testing" {
     
        # mock call to the helper module to isolate Get-TargetResource
        Mock Get-AuditOption { return $optionState } -ModuleName MSFT_xAuditOption

        $get = Get-TargetResource -Name $optionName

        It "Return object is a hashtable" {
            $isHashtable = $get.GetType().Name -eq 'hashtable'
        
            $isHashtable | Should Be $true
        }

        It " that has a 'Name' key" {
            $containsNameKey = $get.ContainsKey('Name')

            $containsNameKey | Should Be $true
        }
    
        It "  with a value of '$optionName'" {
            $retrievedOptionName = $get.Name 
            $retrievedOptionName | Should Be $optionName
        }

        It " that has a 'Value' key" {
            $containsValueKey = $get.ContainsKey('Value')
            $containsValueKey | Should Be $true
        }
    
        It "  with a value of '$optionState'" {
            $get.Value | Should Be $optionState
        }
    }
}

Describe "Set-TargetResource" {
    
    Context "Unit Testing" {

       # mock call to the helper module to isolate Set-TargetResource
        Mock Set-AuditOption {return } -ModuleName MSFT_xAuditOption
        
        $set = Set-TargetResource -Name $optionName -Value $optionState

        It " returns no object" {
        
            $set | Should BeNullOrEmpty
        }
    }
}



Describe "Test-TargetResource unit tests" {

    Context "Unit Testing" {

        # mock call to the helper module to isolate Test-TargetResource
        Mock Get-AuditOption { return $optionState } -ModuleName MSFT_xAuditOption

        $test = Test-TargetResource -Name $optionName -Value $optionState

        It "Return object is a Boolean" {
            $isBool = $test.GetType().Name -eq "Boolean"

            $isBool | Should Be $true
        }

        It " that is true when matching" {
            $valueMatches = $test
        
            $valueMatches | Should Be $true
        }

        It " that is false when not matching" {
            $valueNotMatches = Test-TargetResource -Name $optionName -Value $optionStateSwap[$optionState]
        
            $valueNotMatches | Should Be $false
        }
    }
}