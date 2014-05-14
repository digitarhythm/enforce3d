<?php
$ini = parse_ini_file("lib/config.ini", true);
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="x-ua-compatible" content="IE=Edge">
    <meta name="viewport" content="width=device-width, user-scalable=no, minimal-ui">
    <meta name="apple-mobile-web-app-capable" content="yes">
	<script type="text/javascript" src="usrobject/environ.js"></script>
<?php
    if ($library == "tmlib") {
        echo '<script type="text/javascript" src="extlib/tmlib.min.0.3.0.js"></script>';
        echo '<script type="text/javascript" src="sysobject/enforce.core.tmlib.js"></script>';
        echo '<script type="text/javascript">_setTmlib();</script>';
    } else if ($library == "enchant") {
        echo '<script type="text/javascript" src="extlib/enchant.0.8.0-enforce.js"></script>';
        echo '<script type="text/javascript" src="sysobject/enforce.core.enchant.js"></script>';
        echo '<script type="text/javascript">_setEnchant();</script>';
    }
?>
<?php
    // #################################################################################
    // ライブラリー読み込み
    // #################################################################################
	$srcdir = "./plugins";
	$dir = opendir($srcdir);
	while ($fname = readdir($dir)) {
		if (is_dir($srcdir."/".$fname) || !preg_match("/.*.js/", $fname)) {
			continue;
		}
		echo "<script type='text/javascript' src='$srcdir/$fname'></script>\n";
	}

    // #################################################################################
    // アプリケーションスクリプト読み込み
    // #################################################################################
	$srcdir = "./usrobject";
	$dir = opendir($srcdir);
	while ($fname = readdir($dir)) {
		if (is_dir($srcdir."/".$fname) || preg_match("/environ.js/", $fname)) {
			continue;
		}
		echo "<script type='text/javascript' src='$srcdir/$fname'></script>\n";
	}
?>
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<?php
    if ($library == "tmlib") {
        echo '<body bgcolor="black">';
        echo '<canvas id="stage"></canvas>';
        echo '</body>';
    } else {
        echo '<body bgcolor="black">';
        echo '</body>';
    }
?>
</html>
