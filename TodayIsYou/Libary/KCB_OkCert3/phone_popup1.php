<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// ���ϸ� : phone_popup1.php
	// - �ٴ�������
	// �޴��� ����Ȯ�� ���� ��û ���� �Է� ȭ��
    //**************************************************************************
?>
<html>
<head>
<title>KCB �޴��� ����Ȯ�� ���� ���� 1<</title>
<script>
//<!--
	function jsSubmit(){
		window.open("", "auth_popup", "width=430,height=640,scrollbars=yes");
		var form1 = document.form1;
		form1.target = "auth_popup";
		form1.submit();
	}
//-->
</script>
</head>
<body>
	<div>
		<form name="form1" action="phone_popup2.php" method="post">
			<table>
				<tr>
					<td colspan="2"><strong> - �޴��� ����Ȯ�� ����</strong></td>
				</tr>
				<tr>
					<td>ȸ�����ڵ�</td>
					<td>
						<input type="text" name="CP_CD" maxlength="12" size="16" value="V21130000000">
					</td>
				</tr>
				<tr>
					<td>��û����Ʈ��</td>
					<td>
						<input type="text" name="SITE_NAME" maxlength="20" size="24" value="http://www.todayisyou.co.kr/">
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center"><input type="button" value="�޴��� ����Ȯ��" onClick="jsSubmit();"></td>
				</tr>
			</table>
        </form>
    </div>
	
	<!-- �޴��� ����Ȯ�� �˾� ó����� ���� = phone_popup3 ���� �� �Է� -->
	<form name="kcbResultForm" method="post" >
		<input type="hidden" name="CP_CD" />
		<input type="hidden" name="TX_SEQ_NO" />
		<input type="hidden" name="RSLT_CD" />
		<input type="hidden" name="RSLT_MSG" />
		
		<input type="hidden" name="RSLT_NAME" />
		<input type="hidden" name="RSLT_BIRTHDAY" />
		<input type="hidden" name="RSLT_SEX_CD" />
		<input type="hidden" name="RSLT_NTV_FRNR_CD" />
		
		<input type="hidden" name="DI" />
		<input type="hidden" name="CI" />
		<input type="hidden" name="CI2" />
		<input type="hidden" name="CI_UPDATE" />
		<input type="hidden" name="TEL_COM_CD" />
		<input type="hidden" name="TEL_NO" />
		
		<input type="hidden" name="RETURN_MSG" />
	</form>
</body>
</html>
