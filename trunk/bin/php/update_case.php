<?php
/**
* Desc: Scan direcotry and import relative info into table of Test Case or Test Suite
*
* Jun 14, 2011 created by Litang Tang
* @Copyright Aerohive Networking Inc.
*/
exec('echo $AUTO_WEBROOT', $output);
$globalDocumentRoot = isset($output[0]) ? $output[0] : $_ENV['AUTO_WEBROOT'];
$globalDocumentRoot = rtrim($globalDocumentRoot, '/').'/';
require_once($globalDocumentRoot.'Config/Config.php');
require_once($globalDocumentRoot.'Include/Debug.class.php');
require_once($globalDocumentRoot.'Include/DB.class.php');
$globalDebugTrace = debug_backtrace();
$globalDBInstance = DB::getInstance(DB_HOST, DB_NAME, DB_USER, DB_PWD);
$help = "Usage:
update_case.php [option 'the relative directory of test case file']
Options and Arguments:
	-a, insert the case info to DB.
	-d, set delete flag for the case in DB.
	-u, update the case info to DB
";

if ($argc == 3)
{

	$result = 1;
	$option = $argv[1];
	$path = $argv[2];
	$feature = dirname($path);
	$filename = basename($path);
	$filePath = strtolower($feature) == 'common' ? TESTCASE_COMMON_PATH : TESTCASE_SPECIFIC_PATH;
	$filePath .= $argv[2];
	$pathField = $feature.'/'.$filename;
	$currentTime = time();
	if (file_exists($filePath))
	{
		switch ($option)
		{
			case "-a":
				libxml_use_internal_errors(TRUE);
				$xmlHandle = simplexml_load_file($filePath);
				if ($xmlHandle !== FALSE)
				{
					$arrRow = array(
						'CreateTime' => $currentTime,
						'ModifyTime' => $currentTime,
						'Name' => $filename,
						'Feature' => $feature,
						'Path' => $pathField,
						'Owner' => '',
						'Description' => htmlspecialchars(strval($xmlHandle->brief), ENT_QUOTES),
						'Automated' => strval($xmlHandle->automated),
						'Priority' => strval($xmlHandle->priority),
						'NumberofAP' => strval($xmlHandle->numofap),
						'NumberofStation' => strval($xmlHandle->numofsta),
						'TBType' =>  strval($xmlHandle->tbtype)
					);
				}
				else
				{
					$errMsg = "Failed loading XML '".$filePath."'.\n";
					foreach(libxml_get_errors() as $error) {
						$errMsg .= "\t".$error->message."\n";
						
					}
					libxml_clear_errors();
					echo $errMsg;
					debug(INFO_ERROR_ALL, $globalDebugTrace, $errMsg);
					return 1;
				}

				$sql = "select * from AWP_TestCase where Name='".$arrRow['Name']."'";
				$arrTestScriptExist = $globalDBInstance->query($sql);
				
				if (count($arrTestScriptExist) <= 0)
				{
					$sql = $globalDBInstance->statement('insert', $arrRow, 'AWP_TestCase');
					$result = $globalDBInstance->execute($sql);
					$lastInsertID = $globalDBInstance->lastInsertID();
				}
				else
				{
					$sql = $globalDBInstance->statement('update', $arrRow, 'AWP_TestCase',  " Name='".$arrRow['Name']."'");
					$result = $globalDBInstance->execute($sql);
				}
				if (! $result)  echo $globalDBInstance->errInfo;
				break;
			case "-d":
				$sql = "delete from AWP_TestCase where Path='".$pathField."'";
				$result = $globalDBInstance->execute($sql);
				if (! $result)  echo $globalDBInstance->errInfo;
				break;
			case "-u":
				$xmlHandle = simplexml_load_file($filePath);
				if ($xmlHandle !== FALSE)
				{
					$arrRow = array(
						'CreateTime' => $currentTime,
						'ModifyTime' => $currentTime,
						'Name' => $filename,
						'Feature' => $feature,
						'Path' => $pathField,
						'Owner' => '',
						'Description' => htmlspecialchars(strval($xmlHandle->brief), ENT_QUOTES),
						'Automated' => strval($xmlHandle->automated),
						'Priority' => strval($xmlHandle->priority),
						'NumberofAP' => strval($xmlHandle->numofap),
						'NumberofStation' => strval($xmlHandle->numofsta),
						'TBType' =>  strval($xmlHandle->tbtype)
					);
				}
				else
				{
					echo ("Error: Test Case's format is wrong.");
					return 1;
				}
				$sql = "select * from AWP_TestCase where Name='".$arrRow['Name']."'";
				$arrTestScriptExist = $globalDBInstance->query($sql);
				
				if (count($arrTestScriptExist) <= 0)
				{
					echo('Error: The file not exists in database.');
					return 1;
				}
				else
				{
					$sql = $globalDBInstance->statement('update', $arrRow, 'AWP_TestCase',  " Name='".$arrRow['Name']."'");
					$result = $globalDBInstance->execute($sql);
					if (! $result) echo $globalDBInstance->errInfo;
				}
				break;
			default:
				echo $help;
				break;
		}
	}
	else
	{
		echo ("Error: File '".$filePath."' not exist.");
		return 1;

	}
	$result = $result ? 0 : 1;
	return $result;
}
else
{
	echo $help;
	return 1;
}

?>