# Get Server Users - Lewis Stevens
$userCount = 0;
$outputString = '';

# OUTPUT FILE LOCATION AND FILENAME (THIS HAS DATESTAMP IN IT)
$serverAddress = "\\sharedlocation\"+(hostname)+"\";
$source = $serverAddress+""+(hostname);

# SET NULL ARRAY
$outputArray = @();
$outputArray2 = @();

# RESTRICT USERS
$restrictedUsers = @(
    'SYSTEM',
    'Administrator',
    'ASPNET',
    'Test',
    'Guest'
);

# INPUT FIELDS
$input1 = Read-Host -Prompt "Credentials required for: $serverAddress `r`n`r`nUsername";
$input2 = Read-Host -Prompt "Password" -AsSecureString;


function ChangeToShare{

    if($serverAddress -ne ""){        
        if((get-item $serverAddress).Name){
            echo "Accessing connection to $serverAddress";
        } else {
            echo "Creating connection to $serverAddress";

            # Create Dir for Output
            if((Test-Path $serverAddress) -eq $false){
                mkdir $serverAddress
            }

            # Connects into the share from user input (Can delete if we can ensure it is all connected).
            net use $serverAddress /user:$input1 $input2;
        }
       
        cd $serverAddress;
    } else {
        echo "Share location must have a value";
    }
}

# Change to the share
ChangeToShare


Get-WmiObject -Class win32_useraccount -Filter "Disabled='False'" | Select Name | %{
       
    # Check for restricted users
    $restricted = $FALSE;
    for($i=0; $i -lt $restrictedUsers.Length; $i++){
        if($_.Name.ToUpper() -eq $restrictedUsers[$i].ToUpper()){
            $restricted = $TRUE;
        }
    }

    # Iterate through rows
    if($restricted -eq $FALSE){
        # Count users
        $userCount++;

        # Add name of server
        $hostname = hostname;

        # Creates Object
        $outputArrayInline = New-Object -TypeName PSObject;
            
        # Adds object elements
        $outputArrayInline | Add-Member -MemberType NoteProperty -Name 'Company' -Value $hostname;
        $outputArrayInline | Add-Member -MemberType NoteProperty -Name 'User Count' -Value $userCount;
        $outputArrayInline | Add-Member -MemberType NoteProperty -Name 'Username' -Value $_.Name;

        # Adds object to array.
        $outputArray += $outputArrayInline;
    }
    
}

# Creates txt file for single usercount output
$userCount | Out-File -filepath "$source.txt";

# Creates CSV file with user names etc.
$outputArray | Export-CSV -Path "$source.csv" -NoTypeInformation;