

#Gets all folders in $FullPath - check is SYSTEM is at least read/write - adds it if it isn't
#Goes down one more level and does the same.

#---SET YOUR FOLDER
$FullPath = "D:\Shared\" 
#---SET YOU USER you want with permissions
$UserRef = "NT AUTHORITY\SYSTEM"

#---Edit to set the Permission
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserRef,"ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
		

$Folders = Get-ChildItem -Path $FullPath | ?{ $_.PSIsContainer } | Foreach-Object {$_.Name}
foreach ($F in $Folders)
{
	$folderpath = $FullPath + "\" + $F
	$permission = (Get-ACL -Path $folderpath).Access | ?{$_.IdentityReference -like $UserRef} | Select IdentityReference,FileSystemRights
		if (-not($permission))
		{
			write-host $folderpath
			$ACL = (Get-Item $folderpath).GetAccessControl('Access')
			$ACL.SetAccessRule($AccessRule)
			$ACL | Set-ACL -Path $folderpath
		}
	$finalfolder = Get-ChildItem -Path $folderpath | ?{ $_.PSIsContainer } | Foreach-Object {$_.Name}
	if (-not($finalfolder)){	
		#no folders
	} else {
		foreach ($FF in $finalfolder)
		{
			$finalfolderpath = $folderpath + "\" + $FF 
			$permission = (Get-ACL -Path $finalfolderpath).Access | ?{$_.IdentityReference -like $UserRef} | Select IdentityReference,FileSystemRights
			if (-not($permission))
			{
				write-host $finalfolderpath
				$ACL = (Get-Item $finalfolderpath).GetAccessControl('Access')
				$ACL.SetAccessRule($AccessRule)
				$ACL | Set-ACL -Path $finalfolderpath
			}
			
		}
	}

}


