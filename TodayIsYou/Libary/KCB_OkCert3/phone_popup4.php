<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// ���ϸ� : phone_popup4.php
	// - �ٴ�������
	// �޴��� ����Ȯ�� ���� ��� �Ϸ� ȭ��
	//**************************************************************************
	$CP_CD				= $_REQUEST["CP_CD"];			// ȸ�����ڵ�
	$TX_SEQ_NO			= $_REQUEST["TX_SEQ_NO"];		// �ŷ���ȣ
	$RSLT_CD			= $_REQUEST["RSLT_CD"];		// ����ڵ�
	$RSLT_MSG			= $_REQUEST["RSLT_MSG"];		// ����޼���
	
	$RSLT_NAME			= $_REQUEST["RSLT_NAME"];		// ����
	$RSLT_BIRTHDAY		= $_REQUEST["RSLT_BIRTHDAY"];	// �������
	$RSLT_SEX_CD		= $_REQUEST["RSLT_SEX_CD"];	// ����
	$RSLT_NTV_FRNR_CD	= $_REQUEST["RSLT_NTV_FRNR_CD"];// ���ܱ��α���
	
	$DI					= $_REQUEST["DI"];				// DI
	$CI					= $_REQUEST["CI"];				// CI
	$CI_UPDATE			= $_REQUEST["CI_UPDATE"];		// CI ������Ʈ
	$TEL_COM_CD			= $_REQUEST["TEL_COM_CD"];		// ��Ż��ڵ�
	$TEL_NO				= $_REQUEST["TEL_NO"];			// �޴�����ȣ
	
	$RETURN_MSG			= $_REQUEST["RETURN_MSG"];		// ���ϸ޽���
	
?>
<title>KCB �޴��� ����Ȯ�� ���� ���� 4</title>
</head>
<body>
<h3>�������</h3>
<ul>
  <li>ȸ�����ڵ�	: <?=$CP_CD?> </li>
  <li>�ŷ���ȣ		: <?=$TX_SEQ_NO?> </li>
  <li>����ڵ�		: <?=$RSLT_CD?></li>
  <li>����޼���	: <?=$RSLT_MSG?></li>
 
  <li>����			: <?=$RSLT_NAME?> </li>
  <li>�������		: <?=$RSLT_BIRTHDAY?> </li>
  <li>����			: <?=$RSLT_SEX_CD?> </li>
  <li>���ܱ��α���	: <?=$RSLT_NTV_FRNR_CD?> </li>
  
  <li>DI			: <?=$DI?> </li>
  <li>CI			: <?=$CI?> </li>
  <li>CI������Ʈ	: <?=$CI_UPDATE?> </li>
  <li>��Ż��ڵ�	: <?=$TEL_COM_CD?> </li>
  <li>�޴�����ȣ	: <?=$TEL_NO?> </li>
  
  <li>���ϸ޽���	: <?=$RETURN_MSG?> </li>

</ul>

<br/>
* ���� - M:��, F:��
<br/>
* ���ܱ��α��� - L:������, F:�ܱ���
<br/>
* ��Ż� - 01:SKT, 02:KT, 03:LGU+, 04:SKT�˶���, 05:KT�˶���, 06:LGU+�˶���
</body>
</html>
