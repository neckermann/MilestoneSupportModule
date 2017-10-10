function Restart-MileStoneServices{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName
 
    )
    BEGIN{}
    PROCESS{
        foreach ($Computer in $ComputerName){
            if (Test-CompConnection $Computer){
                Write-Host "Restarting Milestone XProtect Data Collector Server Service on $Computer"
                Invoke-Command -ComputerName $Computer -ScriptBlock {Restart-Service -Name 'Milestone XProtect Data Collector Server'}
                Write-Host "Restarting Milestone XProtect Recording Server Service on $Computer"
                Invoke-Command -ComputerName $Computer -ScriptBlock {Restart-Service -Name 'Milestone XProtect Recording Server'}
                

            }else{
            Write-Output "The Computer you were trying to reach was not on"
            }
        }
    }
    END{}
}



function Get-MilestoneServiceStatus{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName,
        [int]$SleepTime = 60
 
    )
    BEGIN{}
    PROCESS{
        While(1){
            foreach ($Computer in $ComputerName){
                if (Test-CompConnection $Computer){
                   $service1 = (Get-WmiObject -ComputerName $Computer win32_service -Filter "name='Milestone XProtect Data Collector Server'").startname
                $service2 = (Get-WmiObject -ComputerName $Computer win32_service -Filter "name='Milestone XProtect Recording Server'").startname
                $service1status = (Get-Service -ComputerName $Computer -Name 'Milestone XProtect Data Collector Server').status
                $service2status = (Get-Service -ComputerName $Computer -Name 'Milestone XProtect Recording Server').status


                    if ($service1status -eq "Running" -and $service2status -eq "Running"){
                  Write-Host "$computer Data Collector Services are $service1status as $service1" -ForegroundColor White -BackgroundColor Green
                  Write-Host "$computer Recording Services are $service2status as $service2" -ForegroundColor White -BackgroundColor Green
                  }ElseIf ($service1status -eq "Running" -and $service2status -eq "Stopped"){
                  Write-Host "$computer Recording Services are $service2status as $service2" -ForegroundColor White -BackgroundColor Red
                  Write-Host "$computer Data Collector Services are $service1status as $service1" -ForegroundColor White -BackgroundColor Green
                   }ElseIf ($service1status -eq "Stopped" -and $service2status -eq "Running"){
                   Write-Host "$computer Recording Services are $service2status as $service2" -ForegroundColor White -BackgroundColor Green
                   Write-Host "$computer Data Collector Services are $service1status as $service1" -ForegroundColor White -BackgroundColor Red
                    }
           
   
               Else{
              Write-Host "The Server $computer is not online" -ForegroundColor White -BackgroundColor Red}
               }
               Write-Host "Will try again in $SleepTime seconds `n `n `n"
               Start-Sleep -Seconds $SleepTime 

            }
        }
    }
    END{}
}

function Get-MileStoneEventLog{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName
 
    )
    BEGIN{}
    PROCESS{
        foreach ($Computer in $ComputerName){
            if (Test-CompConnection $Computer){
 Get-EventLog -ComputerName $Computer -LogName Application -Source "Milestone*" -Newest 15 |Select-Object TimeGenerated,Source,Message,MachineName
            }else{
            Write-Output "The Computer you were trying to reach was not on"
            }
        }
    }
    END{}
}

function Get-AxisServiceStatus{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName
 
    )
    BEGIN{}
    PROCESS{
        foreach ($Computer in $ComputerName){
            if (Test-CompConnection $Computer){
                Get-Service -ComputerName $computer -Name "AXIS Camera Management" | Select-Object Status,Name    

            }else{
            Write-Output "The Computer you were trying to reach was not on"
            }
        }
    }
    END{}
}
