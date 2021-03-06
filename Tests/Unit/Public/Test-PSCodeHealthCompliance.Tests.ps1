$ModuleName = 'PSCodeHealth'
Import-Module "$PSScriptRoot\..\..\..\$ModuleName\$($ModuleName).psd1" -Force

Describe 'Test-PSCodeHealthCompliance' {
    InModuleScope $ModuleName {

        $Mocks = ConvertFrom-Json (Get-Content -Path "$($PSScriptRoot)\..\..\TestData\MockObjects.json" -Raw)
        
        Context 'The specified health report does not contain any FunctionHealthRecord' {

            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.NoFunctionHealthRecord | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $Results = Test-PSCodeHealthCompliance -HealthReport $HealthReport

            It 'Should not make the "Function" dynamic parameter available' {
                { Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Add-CoverageInfo' } |
                Should Throw "A parameter cannot be found that matches parameter name 'Function'"
            }
            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Should only return objects for the OverallMetrics group' {
                Foreach ( $Result in $Results ) {
                    $Result.SettingsGroup | Should Be 'OverallMetrics'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeTotal"' {
                $LinesOfCodeTotalResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeTotal'})
                $LinesOfCodeTotalResult.WarningThreshold | Should Be 1000
                $LinesOfCodeTotalResult.FailThreshold | Should Be 2000
                $LinesOfCodeTotalResult.HigherIsBetter | Should Be $False
                $LinesOfCodeTotalResult.Value | Should Be 291
                $LinesOfCodeTotalResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeAverage"' {
                $LinesOfCodeAverageResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeAverage'})
                $LinesOfCodeAverageResult.WarningThreshold | Should Be 30
                $LinesOfCodeAverageResult.FailThreshold | Should Be 60
                $LinesOfCodeAverageResult.HigherIsBetter | Should Be $False
                $LinesOfCodeAverageResult.Value | Should Be 0
                $LinesOfCodeAverageResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerErrors"' {
                $ScriptAnalyzerErrorsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerErrors'})
                $ScriptAnalyzerErrorsResult.WarningThreshold | Should Be 1
                $ScriptAnalyzerErrorsResult.FailThreshold | Should Be 3
                $ScriptAnalyzerErrorsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerErrorsResult.Value | Should Be 1
                $ScriptAnalyzerErrorsResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerWarnings"' {
                $ScriptAnalyzerWarningsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerWarnings'})
                $ScriptAnalyzerWarningsResult.WarningThreshold | Should Be 10
                $ScriptAnalyzerWarningsResult.FailThreshold | Should Be 20
                $ScriptAnalyzerWarningsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerWarningsResult.Value | Should Be 4
                $ScriptAnalyzerWarningsResult.Result | Should Be 'Pass'
            }
        }
        Context 'The specified health report contains 2 FunctionHealthRecords' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.'2FunctionHealthRecords' | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $MetricsToTest = @('TestsPassRate','LinesOfCodeTotal','LinesOfCodeAverage','ScriptAnalyzerErrors','ScriptAnalyzerWarnings','CommandsMissed','Complexity','MaximumNestingDepth','LinesOfCode')
            $Results = Test-PSCodeHealthCompliance -HealthReport $HealthReport -MetricName $MetricsToTest

            It 'Should make the "Function" dynamic parameter available' {
                { Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Test-Function1' } |
                Should Not Throw
            }
            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeTotal"' {
                $LinesOfCodeTotalResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeTotal'})
                $LinesOfCodeTotalResult.WarningThreshold | Should Be 1000
                $LinesOfCodeTotalResult.FailThreshold | Should Be 2000
                $LinesOfCodeTotalResult.HigherIsBetter | Should Be $False
                $LinesOfCodeTotalResult.Value | Should Be 187
                $LinesOfCodeTotalResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeAverage"' {
                $LinesOfCodeAverageResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeAverage'})
                $LinesOfCodeAverageResult.WarningThreshold | Should Be 30
                $LinesOfCodeAverageResult.FailThreshold | Should Be 60
                $LinesOfCodeAverageResult.HigherIsBetter | Should Be $False
                $LinesOfCodeAverageResult.Value | Should Be 93.5
                $LinesOfCodeAverageResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerErrors"' {
                $ScriptAnalyzerErrorsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerErrors'})
                $ScriptAnalyzerErrorsResult.WarningThreshold | Should Be 1
                $ScriptAnalyzerErrorsResult.FailThreshold | Should Be 3
                $ScriptAnalyzerErrorsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerErrorsResult.Value | Should Be 2
                $ScriptAnalyzerErrorsResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerWarnings"' {
                $ScriptAnalyzerWarningsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerWarnings'})
                $ScriptAnalyzerWarningsResult.WarningThreshold | Should Be 10
                $ScriptAnalyzerWarningsResult.FailThreshold | Should Be 20
                $ScriptAnalyzerWarningsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerWarningsResult.Value | Should Be 4
                $ScriptAnalyzerWarningsResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "CommandsMissed"' {
                $CommandsMissedResult = $Results.Where({$_.MetricName -eq 'CommandsMissed'})
                $CommandsMissedResult.WarningThreshold | Should Be 6
                $CommandsMissedResult.FailThreshold | Should Be 12
                $CommandsMissedResult.HigherIsBetter | Should Be $False
                $CommandsMissedResult.Value | Should Be 12
                $CommandsMissedResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "Complexity"' {
                $ComplexityResult = $Results.Where({$_.MetricName -eq 'Complexity'})
                $ComplexityResult.WarningThreshold | Should Be 15
                $ComplexityResult.FailThreshold | Should Be 30
                $ComplexityResult.HigherIsBetter | Should Be $False
                $ComplexityResult.Value | Should Be 19
                $ComplexityResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "MaximumNestingDepth"' {
                $MaximumNestingDepthResult = $Results.Where({$_.MetricName -eq 'MaximumNestingDepth'})
                $MaximumNestingDepthResult.WarningThreshold | Should Be 4
                $MaximumNestingDepthResult.FailThreshold | Should Be 8
                $MaximumNestingDepthResult.HigherIsBetter | Should Be $False
                $MaximumNestingDepthResult.Value | Should Be 5
                $MaximumNestingDepthResult.Result | Should Be 'Warning'
            }
        }
        Context 'The Function parameter is specified' {
            $HealthReport = ConvertFrom-Json (Get-Content -Path "$PSScriptRoot\..\..\TestData\HealthReport.json" -Raw)
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $Results = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Add-CoverageInfo'

            It 'Should return object of the type [PSCodeHealth.Compliance.FunctionResult]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.FunctionResult'
                }
            }
            It 'Should return 1 object per metric in group "PerFunctionMetrics"' {
                $Results.Count | Should Be 6
            }
            It 'Should return objects with the property FunctionName "Add-CoverageInfo"' {
                Foreach ( $Result in $Results ) {
                    $Result.FunctionName | Should Be 'Add-CoverageInfo'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCode"' {
                $LinesOfCodeResult = $Results.Where({$_.MetricName -eq 'LinesOfCode'})
                $LinesOfCodeResult.WarningThreshold | Should Be 30
                $LinesOfCodeResult.FailThreshold | Should Be 60
                $LinesOfCodeResult.HigherIsBetter | Should Be $False
                $LinesOfCodeResult.Value | Should Be 14
                $LinesOfCodeResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerFindings"' {
                $ScriptAnalyzerFindingsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerFindings'})
                $ScriptAnalyzerFindingsResult.WarningThreshold | Should Be 7
                $ScriptAnalyzerFindingsResult.FailThreshold | Should Be 12
                $ScriptAnalyzerFindingsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerFindingsResult.Value | Should Be 0
                $ScriptAnalyzerFindingsResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestCoverage"' {
                $TestCoverageResult = $Results.Where({$_.MetricName -eq 'TestCoverage'})
                $TestCoverageResult.WarningThreshold | Should Be 80
                $TestCoverageResult.FailThreshold | Should Be 70
                $TestCoverageResult.HigherIsBetter | Should Be $True
                $TestCoverageResult.Value | Should Be 0
                $TestCoverageResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "CommandsMissed"' {
                $CommandsMissedResult = $Results.Where({$_.MetricName -eq 'CommandsMissed'})
                $CommandsMissedResult.WarningThreshold | Should Be 6
                $CommandsMissedResult.FailThreshold | Should Be 12
                $CommandsMissedResult.HigherIsBetter | Should Be $False
                $CommandsMissedResult.Value | Should Be 3
                $CommandsMissedResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "Complexity"' {
                $ComplexityResult = $Results.Where({$_.MetricName -eq 'Complexity'})
                $ComplexityResult.WarningThreshold | Should Be 15
                $ComplexityResult.FailThreshold | Should Be 30
                $ComplexityResult.HigherIsBetter | Should Be $False
                $ComplexityResult.Value | Should Be 1
                $ComplexityResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "MaximumNestingDepth"' {
                $MaximumNestingDepthResult = $Results.Where({$_.MetricName -eq 'MaximumNestingDepth'})
                $MaximumNestingDepthResult.WarningThreshold | Should Be 4
                $MaximumNestingDepthResult.FailThreshold | Should Be 8
                $MaximumNestingDepthResult.HigherIsBetter | Should Be $False
                $MaximumNestingDepthResult.Value | Should Be 1
                $MaximumNestingDepthResult.Result | Should Be 'Pass'
            }

            $Results2 = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Get-CoverageArray'
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCode"' {
                $LinesOfCodeResult = $Results2.Where({$_.MetricName -eq 'LinesOfCode'})
                $LinesOfCodeResult.WarningThreshold | Should Be 30
                $LinesOfCodeResult.FailThreshold | Should Be 60
                $LinesOfCodeResult.HigherIsBetter | Should Be $False
                $LinesOfCodeResult.Value | Should Be 31
                $LinesOfCodeResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerFindings"' {
                $ScriptAnalyzerFindingsResult = $Results2.Where({$_.MetricName -eq 'ScriptAnalyzerFindings'})
                $ScriptAnalyzerFindingsResult.WarningThreshold | Should Be 7
                $ScriptAnalyzerFindingsResult.FailThreshold | Should Be 12
                $ScriptAnalyzerFindingsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerFindingsResult.Value | Should Be 2
                $ScriptAnalyzerFindingsResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestCoverage"' {
                $TestCoverageResult = $Results2.Where({$_.MetricName -eq 'TestCoverage'})
                $TestCoverageResult.WarningThreshold | Should Be 80
                $TestCoverageResult.FailThreshold | Should Be 70
                $TestCoverageResult.HigherIsBetter | Should Be $True
                $TestCoverageResult.Value | Should Be 94.74
                $TestCoverageResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "CommandsMissed"' {
                $CommandsMissedResult = $Results2.Where({$_.MetricName -eq 'CommandsMissed'})
                $CommandsMissedResult.WarningThreshold | Should Be 6
                $CommandsMissedResult.FailThreshold | Should Be 12
                $CommandsMissedResult.HigherIsBetter | Should Be $False
                $CommandsMissedResult.Value | Should Be 1
                $CommandsMissedResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "Complexity"' {
                $ComplexityResult = $Results2.Where({$_.MetricName -eq 'Complexity'})
                $ComplexityResult.WarningThreshold | Should Be 15
                $ComplexityResult.FailThreshold | Should Be 30
                $ComplexityResult.HigherIsBetter | Should Be $False
                $ComplexityResult.Value | Should Be 5
                $ComplexityResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "MaximumNestingDepth"' {
                $MaximumNestingDepthResult = $Results2.Where({$_.MetricName -eq 'MaximumNestingDepth'})
                $MaximumNestingDepthResult.WarningThreshold | Should Be 4
                $MaximumNestingDepthResult.FailThreshold | Should Be 8
                $MaximumNestingDepthResult.HigherIsBetter | Should Be $False
                $MaximumNestingDepthResult.Value | Should Be 3
                $MaximumNestingDepthResult.Result | Should Be 'Pass'
            }
            $Results3 = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Add-CoverageInfo' -Summary
            It 'Should return "Fail"' {
                $Results3 | Should Be 'Fail'
            }
            $Results4 = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Function 'Get-CoverageArray' -Summary
            It 'Should return "Warning"' {
                $Results4 | Should Be 'Warning'
            }
        }
        Context 'The specified health report contains 2 FunctionHealthRecords and is input via the pipeline' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.'2FunctionHealthRecords' | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $MetricsToTest = @('TestsPassRate','LinesOfCodeTotal','LinesOfCodeAverage','ScriptAnalyzerErrors','ScriptAnalyzerWarnings','Complexity','MaximumNestingDepth','LinesOfCode','TestCoverage')
            $Results = $HealthReport | Test-PSCodeHealthCompliance -MetricName $MetricsToTest

            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeTotal"' {
                $LinesOfCodeTotalResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeTotal'})
                $LinesOfCodeTotalResult.WarningThreshold | Should Be 1000
                $LinesOfCodeTotalResult.FailThreshold | Should Be 2000
                $LinesOfCodeTotalResult.HigherIsBetter | Should Be $False
                $LinesOfCodeTotalResult.Value | Should Be 187
                $LinesOfCodeTotalResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeAverage"' {
                $LinesOfCodeAverageResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeAverage'})
                $LinesOfCodeAverageResult.WarningThreshold | Should Be 30
                $LinesOfCodeAverageResult.FailThreshold | Should Be 60
                $LinesOfCodeAverageResult.HigherIsBetter | Should Be $False
                $LinesOfCodeAverageResult.Value | Should Be 93.5
                $LinesOfCodeAverageResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerErrors"' {
                $ScriptAnalyzerErrorsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerErrors'})
                $ScriptAnalyzerErrorsResult.WarningThreshold | Should Be 1
                $ScriptAnalyzerErrorsResult.FailThreshold | Should Be 3
                $ScriptAnalyzerErrorsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerErrorsResult.Value | Should Be 2
                $ScriptAnalyzerErrorsResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerWarnings"' {
                $ScriptAnalyzerWarningsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerWarnings'})
                $ScriptAnalyzerWarningsResult.WarningThreshold | Should Be 10
                $ScriptAnalyzerWarningsResult.FailThreshold | Should Be 20
                $ScriptAnalyzerWarningsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerWarningsResult.Value | Should Be 4
                $ScriptAnalyzerWarningsResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "Complexity"' {
                $ComplexityResult = $Results.Where({$_.MetricName -eq 'Complexity'})
                $ComplexityResult.WarningThreshold | Should Be 15
                $ComplexityResult.FailThreshold | Should Be 30
                $ComplexityResult.HigherIsBetter | Should Be $False
                $ComplexityResult.Value | Should Be 19
                $ComplexityResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "MaximumNestingDepth"' {
                $MaximumNestingDepthResult = $Results.Where({$_.MetricName -eq 'MaximumNestingDepth'})
                $MaximumNestingDepthResult.WarningThreshold | Should Be 4
                $MaximumNestingDepthResult.FailThreshold | Should Be 8
                $MaximumNestingDepthResult.HigherIsBetter | Should Be $False
                $MaximumNestingDepthResult.Value | Should Be 5
                $MaximumNestingDepthResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestCoverage"' {
                $TestCoverageResult = $Results.Where({$_.MetricName -eq 'TestCoverage'}) | Where-Object { $_.SettingsGroup -eq 'PerFunctionMetrics'}
                $TestCoverageResult.WarningThreshold | Should Be 80
                $TestCoverageResult.FailThreshold | Should Be 70
                $TestCoverageResult.HigherIsBetter | Should Be $True
                $TestCoverageResult.Value | Should Be 79
                $TestCoverageResult.Result | Should Be 'Warning'
            }
        }
        Context 'The specified health report contains 2 FunctionHealthRecords and SettingsGroup is specified' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.'2FunctionHealthRecords' | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $MetricsToTest = @('TestsPassRate','LinesOfCodeTotal','LinesOfCodeAverage','ScriptAnalyzerErrors','ScriptAnalyzerWarnings','Complexity','MaximumNestingDepth','LinesOfCode')
            $Results = $HealthReport | Test-PSCodeHealthCompliance -MetricName $MetricsToTest -SettingsGroup OverallMetrics

            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Should only return objects for the OverallMetrics group' {
                Foreach ( $Result in $Results ) {
                    $Result.SettingsGroup | Should Be 'OverallMetrics'
                }
            }
            It 'Should return objects for 5 metrics' {
                $Results.Count | Should Be 5
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeTotal"' {
                $LinesOfCodeTotalResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeTotal'})
                $LinesOfCodeTotalResult.WarningThreshold | Should Be 1000
                $LinesOfCodeTotalResult.FailThreshold | Should Be 2000
                $LinesOfCodeTotalResult.HigherIsBetter | Should Be $False
                $LinesOfCodeTotalResult.Value | Should Be 187
                $LinesOfCodeTotalResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeAverage"' {
                $LinesOfCodeAverageResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeAverage'})
                $LinesOfCodeAverageResult.WarningThreshold | Should Be 30
                $LinesOfCodeAverageResult.FailThreshold | Should Be 60
                $LinesOfCodeAverageResult.HigherIsBetter | Should Be $False
                $LinesOfCodeAverageResult.Value | Should Be 93.5
                $LinesOfCodeAverageResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerErrors"' {
                $ScriptAnalyzerErrorsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerErrors'})
                $ScriptAnalyzerErrorsResult.WarningThreshold | Should Be 1
                $ScriptAnalyzerErrorsResult.FailThreshold | Should Be 3
                $ScriptAnalyzerErrorsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerErrorsResult.Value | Should Be 2
                $ScriptAnalyzerErrorsResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "ScriptAnalyzerWarnings"' {
                $ScriptAnalyzerWarningsResult = $Results.Where({$_.MetricName -eq 'ScriptAnalyzerWarnings'})
                $ScriptAnalyzerWarningsResult.WarningThreshold | Should Be 10
                $ScriptAnalyzerWarningsResult.FailThreshold | Should Be 20
                $ScriptAnalyzerWarningsResult.HigherIsBetter | Should Be $False
                $ScriptAnalyzerWarningsResult.Value | Should Be 4
                $ScriptAnalyzerWarningsResult.Result | Should Be 'Pass'
            }
        }
        Context 'The specified health report contains 2 FunctionHealthRecords and CustomSettingsPath is specified' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.'2FunctionHealthRecords' | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $MetricsInBothGroups = "$PSScriptRoot\..\..\TestData\2SettingsGroups4Metrics.json"
            $MetricsToTest = @('TestsPassRate','LinesOfCodeTotal','LinesOfCodeAverage','Complexity','MaximumNestingDepth','LinesOfCode')
            $Results = $HealthReport | Test-PSCodeHealthCompliance -MetricName $MetricsToTest -CustomSettingsPath $MetricsInBothGroups

            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeTotal"' {
                $LinesOfCodeTotalResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeTotal'})
                $LinesOfCodeTotalResult.WarningThreshold | Should Be 1500
                $LinesOfCodeTotalResult.FailThreshold | Should Be 3000
                $LinesOfCodeTotalResult.HigherIsBetter | Should Be $False
                $LinesOfCodeTotalResult.Value | Should Be 187
                $LinesOfCodeTotalResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCodeAverage"' {
                $LinesOfCodeAverageResult = $Results.Where({$_.MetricName -eq 'LinesOfCodeAverage'})
                $LinesOfCodeAverageResult.WarningThreshold | Should Be 21
                $LinesOfCodeAverageResult.FailThreshold | Should Be 42
                $LinesOfCodeAverageResult.HigherIsBetter | Should Be $False
                $LinesOfCodeAverageResult.Value | Should Be 93.5
                $LinesOfCodeAverageResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "Complexity"' {
                $ComplexityResult = $Results.Where({$_.MetricName -eq 'Complexity'})
                $ComplexityResult.WarningThreshold | Should Be 17
                $ComplexityResult.FailThreshold | Should Be 33
                $ComplexityResult.HigherIsBetter | Should Be $False
                $ComplexityResult.Value | Should Be 19
                $ComplexityResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "MaximumNestingDepth"' {
                $MaximumNestingDepthResult = $Results.Where({$_.MetricName -eq 'MaximumNestingDepth'})
                $MaximumNestingDepthResult.WarningThreshold | Should Be 6
                $MaximumNestingDepthResult.FailThreshold | Should Be 12
                $MaximumNestingDepthResult.HigherIsBetter | Should Be $False
                $MaximumNestingDepthResult.Value | Should Be 5
                $MaximumNestingDepthResult.Result | Should Be 'Pass'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "LinesOfCode"' {
                $LinesOfCodeResult = $Results.Where({$_.MetricName -eq 'LinesOfCode'})
                $LinesOfCodeResult.WarningThreshold | Should Be 30
                $LinesOfCodeResult.FailThreshold | Should Be 60
                $LinesOfCodeResult.HigherIsBetter | Should Be $False
                $LinesOfCodeResult.Value | Should Be 101
                $LinesOfCodeResult.Result | Should Be 'Fail'
            }
        }
        Context 'The specified health report contains 2 FunctionHealthRecords and CustomSettingsPath is specified' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.'1FunctionHealthRecord' | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $MetricsInBothGroups = "$PSScriptRoot\..\..\TestData\2SettingsGroups4Metrics.json"
            $MetricsToTest = @('TestsPassRate','TestCoverage')
            $Results = $HealthReport | Test-PSCodeHealthCompliance -MetricName $MetricsToTest -CustomSettingsPath $MetricsInBothGroups

            It 'Should return objects of the type [PSCodeHealth.Compliance.Result]' {
                Foreach ( $Result in $Results ) {
                    $Result | Should BeOfType [PSCustomObject]
                    ($Result | Get-Member).TypeName[0] | Should Be 'PSCodeHealth.Compliance.Result'
                }
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestsPassRate"' {
                $TestsPassRateResult = $Results.Where({$_.MetricName -eq 'TestsPassRate'})
                $TestsPassRateResult.WarningThreshold | Should Be 99
                $TestsPassRateResult.FailThreshold | Should Be 97
                $TestsPassRateResult.HigherIsBetter | Should Be $True
                $TestsPassRateResult.Value | Should Be 90
                $TestsPassRateResult.Result | Should Be 'Fail'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestCoverage"' {
                $TestCoverageResult = $Results.Where({$_.MetricName -eq 'TestCoverage'}) | Where-Object { $_.SettingsGroup -eq 'OverallMetrics'}
                $TestCoverageResult.WarningThreshold | Should Be 80
                $TestCoverageResult.FailThreshold | Should Be 70
                $TestCoverageResult.HigherIsBetter | Should Be $True
                $TestCoverageResult.Value | Should Be 77
                $TestCoverageResult.Result | Should Be 'Warning'
            }
            It 'Resulting compliance rules are the same as the defaults for metric "TestCoverage"' {
                $TestCoverageResult = $Results.Where({$_.MetricName -eq 'TestCoverage'}) | Where-Object { $_.SettingsGroup -eq 'PerFunctionMetrics'}
                $TestCoverageResult.WarningThreshold | Should Be 80
                $TestCoverageResult.FailThreshold | Should Be 70
                $TestCoverageResult.HigherIsBetter | Should Be $True
                $TestCoverageResult.Value | Should Be 95
                $TestCoverageResult.Result | Should Be 'Pass'
            }
        }
        Context 'The Summary parameter is specified and there is a compliance result equal to "Fail"' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.NoFunctionHealthRecord | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            $SummaryResult = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Summary

            It 'Should return a [string]' {
                $SummaryResult | Should BeOfType [string]
            }
            It 'Should return "Fail"' {
                $SummaryResult | Should Be 'Fail'
            }
        }
        Context 'The Summary parameter is specified and compliance results are all equal to "Warning" or "Pass"' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.NoFunctionHealthRecord | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            Mock New-PSCodeHealthComplianceResult { $Mocks.'New-PSCodeHealthComplianceResult'.WarningsAndPass | Where-Object { $_ } }
            $SummaryResult = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Summary

            It 'Should return a [string]' {
                $SummaryResult | Should BeOfType [string]
            }
            It 'Should return "Warning"' {
                $SummaryResult | Should Be 'Warning'
            }
        }
        Context 'The Summary parameter is specified and compliance results are all equal to "Pass"' {
            $HealthReport = $Mocks.'Invoke-PSCodeHealth'.NoFunctionHealthRecord | Where-Object { $_ }
            $HealthReport.psobject.TypeNames.Insert(0, 'PSCodeHealth.Overall.HealthReport')
            Mock New-PSCodeHealthComplianceResult { $Mocks.'New-PSCodeHealthComplianceResult'.AllPass | Where-Object { $_ } }
            $SummaryResult = Test-PSCodeHealthCompliance -HealthReport $HealthReport -Summary

            It 'Should return "Pass"' {
                $SummaryResult | Should Be 'Pass'
            }
        }
    }
}