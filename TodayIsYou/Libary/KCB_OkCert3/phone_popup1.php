<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// 파일명 : phone_popup1.php
	// - 바닥페이지
	// 휴대폰 본인확인 서비스 요청 정보 입력 화면
    //**************************************************************************
?>
<html>
<head>
<title>KCB 휴대폰 본인확인 서비스 샘플 1<</title>
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
					<td colspan="2"><strong> - 휴대폰 본인확인 인증</strong></td>
				</tr>
				<tr>
					<td>회원사코드</td>
					<td>
						<input type="text" name="CP_CD" maxlength="12" size="16" value="V21130000000">
					</td>
				</tr>
				<tr>
					<td>요청사이트명</td>
					<td>
						<input type="text" name="SITE_NAME" maxlength="20" size="24" value="http://www.todayisyou.co.kr/">
					</td>
				</tr>
				<tr>
					<td colspan="2" align="center"><input type="button" value="휴대폰 본인확인" onClick="jsSubmit();"></td>
				</tr>
			</table>
        </form>
    </div>
	
	<!-- 휴대폰 본인확인 팝업 처리결과 정보 = phone_popup3 에서 값 입력 -->
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
