<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// ���ϸ� : phone_popup3.php
	// - �˾�������
	// �޴��� ����Ȯ�� ���� ���� ��� ȭ��(return url).
	// ��ȣȭ�� ������������� ��ȣȭ�Ѵ�.
	//**************************************************************************
	
	/**************************************************************************
	 * okcert3 ����Ȯ�� ���� �Ķ����
	 **************************************************************************/
	/* �˾�â ���� �׸� */
	$MDL_TKN	=	$_REQUEST["mdl_tkn"];			// �����ū

	// ########################################################################
	// # KCB�κ��� �ο����� ȸ�����ڵ�(���̵�) ���� (12�ڸ�)
	// ########################################################################
	$CP_CD = "V06880000000";				// ȸ�����ڵ�(���̵�)
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    //' Ÿ�� : �/�׽�Ʈ ��ȯ�� ���� �ʿ�
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$target = "PROD"; // �׽�Ʈ="TEST", �="PROD"
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    //' ���̼��� ����
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$license = "C:\\okcert3_license\\".$CP_CD."_IDS_01_".$target."_AES_license.dat";
	
	
	/**************************************************************************
	okcert3 request param JSON String
	**************************************************************************/
	$params = '{ "MDL_TKN":"'.$MDL_TKN.'" }';
    
	
	$svcName = "IDS_HS_POPUP_RESULT";
	$out = NULL;
	
	// okcert3 ����
	//$ret = okcert3_u($target, $CP_CD, $svcName, $params, $license, $out);  // UTF-8
	$ret = okcert3($target, $CP_CD, $svcName, $params, $license, $out);  // EUC-KR
	
	/**************************************************************************
	okcert3 ���� ����
	**************************************************************************/
	$RSLT_CD = "";						// ����ڵ�
	$RSLT_MSG = "";						// ����޽���
	$TX_SEQ_NO = "";					// �ŷ��Ϸù�ȣ
	
	$RSLT_NAME		= "";
	$RSLT_BIRTHDAY 	= "";
	$RSLT_SEX_CD	= "";
	$RSLT_NTV_FRNR_CD="";
	
	$DI				= "";
	$CI				= "";
	$CI_UPDATE		= "";
	$TEL_COM_CD		= "";
	$TEL_NO			= "";
	
	$RETURN_MSG 	= "";				// ���ϸ޽���

	if($ret == 0) {		// �Լ� ���� ������ ��� ������ ������� ����
		$out = iconv("euckr","utf-8",$out);		// ���ڵ� icnov ó��. okcert3 ȣ��(EUC-KR)�� ��쿡�� ��� (json_decode�� UTF-8�� ����)
		$output = json_decode($out,true);		// $output = UTF-8
		
		$RSLT_CD	= $output['RSLT_CD'];
		$RSLT_MSG  = iconv("utf-8","euckr", $output["RSLT_MSG"]);	// �ٽ� EUC-KR �� ��ȯ
		
		if(isset($output["TX_SEQ_NO"])) $TX_SEQ_NO = $output["TX_SEQ_NO"]; // �ʿ� �� �ŷ� �Ϸ� ��ȣ �� ���Ͽ� DB���� ���� ó��
		if(isset($output["RETURN_MSG"]))  $RETURN_MSG  = $output['RETURN_MSG'];
		
		if( $RSLT_CD == "B000" ) { // B000 : �����
			$RSLT_NAME  = iconv("utf-8","euckr",$output['RSLT_NAME']); // �ٽ� EUC-KR �� ��ȯ
			$RSLT_BIRTHDAY	= $output['RSLT_BIRTHDAY'];
			$RSLT_SEX_CD	= $output['RSLT_SEX_CD'];
			$RSLT_NTV_FRNR_CD=$output['RSLT_NTV_FRNR_CD'];
			
			$DI				= $output['DI'];
			$CI 			= $output['CI'];
			$CI_UPDATE		= $output['CI_UPDATE'];
			$TEL_COM_CD		= $output['TEL_COM_CD'];
			$TEL_NO			= $output['TEL_NO'];
		}
	}
?>
<title>KCB �޴��� ����Ȯ�� ���� ���� 3</title>
<script language="javascript" type="text/javascript" >
	function fncOpenerSubmit() {
		opener.document.kcbResultForm.CP_CD.value    	= "<?=$CP_CD?>";
		opener.document.kcbResultForm.TX_SEQ_NO.value 	= "<?=$TX_SEQ_NO?>";
		opener.document.kcbResultForm.RSLT_CD.value		= "<?=$RSLT_CD?>";
		opener.document.kcbResultForm.RSLT_MSG.value	= "<?=$RSLT_MSG?>";
		opener.document.kcbResultForm.RETURN_MSG.value	= "<?=$RETURN_MSG?>";
<?php
 	if ($ret == 0) {
?>
		opener.document.kcbResultForm.RSLT_NAME.value        = "<?=$RSLT_NAME?>";
		opener.document.kcbResultForm.RSLT_BIRTHDAY.value    = "<?=$RSLT_BIRTHDAY?>";
		opener.document.kcbResultForm.RSLT_SEX_CD.value      = "<?=$RSLT_SEX_CD?>";
		opener.document.kcbResultForm.RSLT_NTV_FRNR_CD.value = "<?=$RSLT_NTV_FRNR_CD?>";
		
		opener.document.kcbResultForm.DI.value          = "<?=$DI?>";
		opener.document.kcbResultForm.CI.value          = "<?=$CI?>";
		opener.document.kcbResultForm.CI_UPDATE.value   = "<?=$CI_UPDATE?>";
		opener.document.kcbResultForm.TEL_COM_CD.value  = "<?=$TEL_COM_CD?>";
		opener.document.kcbResultForm.TEL_NO.value      = "<?=$TEL_NO?>";
<?php
	}
?>	
		opener.document.kcbResultForm.action = "phone_popup4.php";
		
		opener.document.kcbResultForm.submit();
		self.close();
	}	
</script>
</head>
<body>
<?php
	if($ret == 0) {
		//������� ��ȣȭ ����
		// ��������� Ȯ���Ͽ� �������б���� ó���� �����ؾ��Ѵ�.
	 	if ($RSLT_CD == "B000") {
			echo ("<script>alert('������������'); fncOpenerSubmit();</script>");
		}
		else {
			echo ("<script>alert('������������ : ".$RSLT_CD." : ".$RSLT_MSG."'); fncOpenerSubmit();</script>");
		}
	} else {
		//������� ��ȣȭ ����
		echo ("<script>alert('���������ȣȭ ���� : ".$ret."'); self.close(); </script>");
	}
?>
</body>
</html>
