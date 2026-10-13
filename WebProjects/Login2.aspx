<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login2.aspx.cs" Inherits="Solva.WebProjects.Login2" EnableEventValidation="false" %>
<%@ Register TagPrefix="cc1" Namespace="Solva.FrameWork20.Fw20_CustomControls" Assembly="Solva.FrameWork20.Fw20_CustomControls" %>

<!DOCTYPE html>
<html lang="ko">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <title runat="server" id="headTitle">SOLVA</title>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%-- 시안 2 : 전체 화면 배경 슬라이드 + 중앙 로그인 카드 --%>
    <link id="lnkLoginCss" runat="server" type="text/css" rel="stylesheet" href="/CommonScripts/Css/Login2.css" />
    <script src="CommonScripts/Js/jquery-3.7.1.min.js" type="text/javascript"></script>

    <script src="CommonScripts/Js/jquery.cookie.js" type="text/javascript"></script>
    <script type="text/javascript" src="/CommonScripts/Js/BasicScript.js?v=<%#nowYMDHM %>"></script>
    <script type="text/javascript" src="/CommonScripts/Js/PopupScript.js?v=<%#nowYMDHM %>"></script>
    <script type="text/javascript" src="/CommonScripts/Js/Webservice.js"></script>
    <script type="text/javascript">
        //모바일, pc 분기처리
        $(document).ready(function () {
            var isMobileServer = String($("#hidIsMobile").val() || "").trim().toLowerCase() === "true";

            // 화면 너비가 768px 이하이면 모바일로 판단 (반응형 대응)
            var isMobileClient = window.innerWidth <= 768;

            // 서버 감지 결과 또는 클라이언트 화면 폭 기준 중 하나라도 모바일이면 mobile-ver 부여
            if (isMobileServer || isMobileClient) {
                $("body").addClass("mobile-ver");
            } else {
                $("body").addClass("pc-ver");
            }
        });

        let arrMsgByLang = [];      // 메세지(다국어)

        $(document).ready(function () {

            // 배경 이미지 슬라이드 시작
            fnStartBgSlide();

            // 독립된 client의 경우 처음에 사용 언어 정보를 읽어옴
            if (chkNullorEmptyToStr($("#hdAppClientCd").val()) != "CQMS") {
                // 사용 언어
                fnSetLangList();
                fnOtpView();
            }
            else {
                $("#cboCountry").append($('<option>', {
                    value: "KOR",
                    text: "Korean"
                }));
            }

            // 독립된 client의 경우 처음에 메세지(다국어) 정보를 읽어옴
            if (chkNullorEmptyToStr($("#hdAppClientCd").val()) != "CQMS") {
                // 메세지(다국어)
                fnGetMsgByLang($("#cboCountry").val());
            }

            // 저장된 쿠키값을 가져와서 ID 칸에 넣어준다. 없으면 공백으로 들어감.
            var userInputId = fnGetCookie("userInputId");
            $("input[name='txtID']").val(userInputId);

            if ($("input[name='txtID']").val() != "") { // 그 전에 ID를 저장해서 처음 페이지 로딩 시, 입력 칸에 저장된 ID가 표시된 상태라면,
                $("#idSaveCheck").attr("checked", true); // ID 저장하기를 체크 상태로 두기.
            }

            $("#idSaveCheck").change(function () { // 체크박스에 변화가 있다면,
                if ($("#idSaveCheck").is(":checked")) { // ID 저장하기 체크했을 때,
                    var userInputId = $("input[name='txtID']").val();
                    fnSetCookie("userInputId", userInputId, 7); // 7일 동안 쿠키 보관
                } else { // ID 저장하기 체크 해제 시,
                    fnDeleteCookie("userInputId");
                }
            });

            // ID 저장하기를 체크한 상태에서 ID를 입력하는 경우, 이럴 때도 쿠키 저장.
            $("input[name='txtID']").keyup(function () { // ID 입력 칸에 ID를 입력할 때,
                if ($("#idSaveCheck").is(":checked")) { // ID 저장하기를 체크한 상태라면,
                    var userInputId = $("input[name='txtID']").val();
                    fnSetCookie("userInputId", userInputId, 7); // 7일 동안 쿠키 보관
                }
            });

            //체크 박스 옆에 span 클릭시 체크박스 클릭한 것 처럼
            $(".chk + label + span").on("click", function () {
                $(".chk + label").trigger("click");
            });

        });

        // ===== 배경 이미지 슬라이드 =====
        // ul.login_bg > li 를 순서대로 돌며 .on 클래스를 옮긴다. (CSS transition 으로 크로스페이드)
        // 슬라이드 추가/삭제는 아래 <ul class="login_bg"> 의 <li> 만 편집하면 된다.
        var bgSlideTimer = null;
        var bgSlideIdx = 0;
        var BG_SLIDE_INTERVAL = 4000;   // 전환 주기(ms)

        function fnStartBgSlide() {
            var $li = $(".login_bg > li");
            if ($li.length <= 1) { $li.first().addClass("on"); return; }

            // 인디케이터(점) 생성
            var $dots = $(".login_bg_dots");
            $li.each(function (i) {
                $dots.append($("<span>").attr("data-idx", i).on("click", function () {
                    fnGoBgSlide(parseInt($(this).attr("data-idx"), 10));
                    fnRestartBgSlide();
                }));
            });

            fnGoBgSlide(0);
            fnRestartBgSlide();
        }

        function fnRestartBgSlide() {
            if (bgSlideTimer) clearInterval(bgSlideTimer);
            bgSlideTimer = setInterval(function () {
                fnGoBgSlide(bgSlideIdx + 1);
            }, BG_SLIDE_INTERVAL);
        }

        function fnGoBgSlide(idx) {
            var $li = $(".login_bg > li");
            bgSlideIdx = (idx + $li.length) % $li.length;
            $li.removeClass("on").eq(bgSlideIdx).addClass("on");
            $(".login_bg_dots > span").removeClass("on").eq(bgSlideIdx).addClass("on");
        }

        function LoginCheck(e) {
            let chkMsg_ID = "ID: Please enter a value";
            let chkMsg_PWD = "Password: Please enter a value";
            let chkMsg_OTP = "OTP: Please enter a value";

            if (arrMsgByLang.length != 0) {
                // ID : 값을 입력해주세요
                chkMsg_ID = arrMsgByLang.find(x => x.key == "M1848") ? arrMsgByLang.find(x => x.key == "M1848").value : chkMsg_ID;
                // Password : 값을 입력해주세요
                chkMsg_PWD = arrMsgByLang.find(x => x.key == "M1849") ? arrMsgByLang.find(x => x.key == "M1849").value : chkMsg_PWD;
                // OTP : 값을 입력해주세요
                chkMsg_OTP = arrMsgByLang.find(x => x.key == "M1905") ? arrMsgByLang.find(x => x.key == "M1905").value : chkMsg_OTP;
            }

            let userId = chkNullorEmptyToStr($("#txtID").val());
            let userPwd = chkNullorEmptyToStr($("#txtPWD").val());
            let userOtp = chkNullorEmptyToStr($("#txtOtp").val());

            let useOtp = chkNullorEmptyToStr($("#hdUseOtp").val());
            let userType = chkNullorEmptyToStr($("#hdUserType").val());

            if (userId == "") {
                alert(chkMsg_ID);
                return false;
            }
            if (userPwd == "") {
                alert(chkMsg_PWD);
                return false;
            }

            if (useOtp == "A" || (useOtp == "I" && userType == "1") || (useOtp == "P" && userType == "2")) {
                if (userOtp == "") {
                    alert(chkMsg_OTP);
                    return false;
                }
            }

            let countryVal = $("#cboCountry").val();

            fnSetCookie("cboCountry", countryVal, 7);

            if ($("#idSaveCheck").is(":checked")) {
                fnSetCookie("txtID", userId, 7);
            }
            else {
                fnSetCookie("txtID", userId, 0);
            }

            fnLogin(e);
        }

        function fnLogin(e) {
            if (e) e.preventDefault(); // 브라우저의 기본 페이지 이동/전송 동작을 막음

            let userId = chkNullorEmptyToStr($("#txtID").val());
            let userPwd = chkNullorEmptyToStr($("#txtPWD").val());
            let otpNum = chkNullorEmptyToStr($("#txtOtp").val());

            let useOtp = chkNullorEmptyToStr($("#hdUseOtp").val());
            let userType = chkNullorEmptyToStr($("#hdUserType").val());

            let fromGW = chkNullorEmptyToStr($("#hidFromGW").val());

            // 로그인 처리 WebMethod 는 Login.aspx 의 것을 그대로 사용한다.
            fetch("/Login.aspx/LoginProc", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ loginId: userId, userPwd: userPwd, otpNum: otpNum, useOtp: useOtp, userType: userType, fromGW: fromGW })
            })
                .then(response => {
                    if (!response.ok) {
                        alert("server error");
                    }

                    return response.json();
                })
                .then(result => {
                    let ret = result.d.split("|");

                    if (ret[0] == "X" || ret[0] == "N") {
                        alert(ret[1].replace(/\\n/g, "\n"));
                    }
                    else if (ret[0] == "R") {
                        fnUserPwdMod(userId);
                    }
                    else if (ret[0] == "H") {
                        alert(ret[1]);
                        fnUserPwdMod(userId);
                    }
                    else if (ret[0] == "Y") {
                        //모바일에서 접속했는지 여부 쿠키에 저장
                        fnSetCookie("is_mobile", $("#hidIsMobile").val(), 1);
                        fnSetCookie("is_mobile_chksui", chkAndSetParamEncode(userId), 1);

                        location.href = "/App";
                    }
                })
                .catch(error => {
                    alert("error occurred:" + error);
                });
        }

        //onKeyUp일때 Enter치면 버튼클릭되도록함.//
        function EnterCheck() {
            if (event.keyCode == 13) {
                document.all("btnLogin").click();
            }
            return false;
        }


        function fnSetLangList() {
            var qms = new QmsResponse();
            qms.CallWebService("/CommonPages/CallBindHttp.asmx/GetClientUseLanguageList", "loginId=" + $("#txtID").val()); //웹서비스호출

            if (qms.iserror) {
                alert(qms.errormsg);
                $("#txtID").val("");
                $("#txtPWD").val();
                return false;
            }
            else {
                if (qms.sResult == "N") {
                    $("#cboCountry").empty();
                    $("#cboCountry").append($('<option>', {
                        value: "KOR",
                        text: "Korean"
                    }));
                }
                else {
                    $("#cboCountry").empty();

                    for (var i = 0; i < qms.resultcount; i++) {
                        $("#cboCountry").append($('<option>', {
                            value: qms.result[i].code,
                            text: qms.result[i].value
                        }));
                    }

                    let cookieCountry = fnGetCookie("country_code");

                    if (cookieCountry.toString() != "") {
                        $("#cboCountry").val(cookieCountry);
                    }
                    else {
                        fnSetCookie("country_code", $("#cboCountry").val(), 7);
                    }

                    if (chkNullorEmptyToStr($("#hdAppClientCd").val()) == "CQMS") {
                        // 메세지(다국어)
                        fnGetMsgByLang($("#cboCountry").val());
                    }
                }
            }
        }

        function fnGetMsgByLang(langFg) {
            var qms = new QmsResponse();
            qms.CallWebService("/CommonPages/CallBindHttp.asmx/GetMsgByLanguageList", "arrMsgNo=M1166,M1848,M1849,M1905,M1946,M1948&langFg=" + langFg + "&pgmId=Login"); //웹서비스호출

            if (qms.iserror) {
                alert(qms.errormsg);
                return false;
            }
            else {
                for (var i = 0; i < qms.resultcount; i++) {
                    arrMsgByLang.push({ key: qms.result[i].code, value: qms.result[i].value });
                }
            }
        }

        function fnCboCountryChange() {
            arrMsgByLang = [];

            // 메세지(다국어) 변경
            fnGetMsgByLang($("#cboCountry").val());

            fnSetCookie("country_code", $("#cboCountry").val(), 7);
        }

        function fnIdChange() {
            // CQMS의 경우 ID를 입력했을때 사용 언어 정보를 읽어옴
            if (chkNullorEmptyToStr($("#hdAppClientCd").val()) == "CQMS") {
                // 사용 언어
                fnSetLangList();
            }

            fnOtpView();

            $("#imgOtpQr").hide();
            $("#divOtpReg").hide();
        }

        function fnPwdChange() {
            $("#imgOtpQr").hide();
            $("#divOtpReg").hide();
        }

        function fnUserPwdMod(userId) {
            _layerPopLibrary.PopupLayer("PwdMod.aspx?userId=" + chkAndSetParamEncode(userId), { type: "popup-mem", changeYn: 'Y', width: 550, height: 260, left: 150, top: 150 }, "");
            return false;
        }

        // OTP 사용 여부를 확인
        function fnOtpView() {
            let pLoginId = $("#txtID").val();

            $("#hdUseOtp").val("");
            $("#hdUserType").val("");

            if (chkNullorEmptyToStr(pLoginId) != "") {
                fetch("/Login.aspx/ChkUseOtp", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({ loginId: pLoginId })
                })
                    .then(response => {
                        if (!response.ok) {
                            alert("server error");
                        }

                        return response.json();
                    })
                    .then(result => {
                        let ret = result.d;
                        let useOtp = "", userType = "";

                        if (ret.msg != "OK") {
                            alert(ret.msg);
                        }
                        else {
                            useOtp = ret.data1;
                            userType = ret.data2;

                            if (userType != "X" && (useOtp == "A" || (useOtp == "I" && userType == "1") || (useOtp == "P" && userType == "2"))) {
                                $("#loginInfo_otp").show();
                                $("#btnOtpRegView").show();
                            }
                            else {
                                $("#loginInfo_otp").hide();
                                $("#btnOtpRegView").hide();
                            }

                            $("#hdUseOtp").val(useOtp);
                            $("#hdUserType").val(userType);
                        }
                    })
                    .catch(error => {
                        alert("error occurred:" + error);
                    });
            }
            else {
                $("#loginInfo_otp").hide();
                $("#btnOtpRegView").hide();
            }
        }

        // [OTP Register] 클릭 시
        function fnOtpReg() {
            let chkMsg_ID = "ID: Please enter a value";
            let chkMsg_PWD = "Password: Please enter a value";
            let reMsg_1 = "The ID or password does not match.";

            let userId = chkNullorEmptyToStr($("#txtID").val());
            let userPwd = chkNullorEmptyToStr($("#txtPWD").val());

            if (arrMsgByLang.length != 0) {
                // ID : 값을 입력해주세요
                chkMsg_ID = arrMsgByLang.find(x => x.key == "M1848") ? arrMsgByLang.find(x => x.key == "M1848").value : chkMsg_ID;
                // Password : 값을 입력해주세요
                chkMsg_PWD = arrMsgByLang.find(x => x.key == "M1849") ? arrMsgByLang.find(x => x.key == "M1849").value : chkMsg_PWD;
                // 아이디 또는 비밀번호가 일치하지 않습니다.
                reMsg_1 = arrMsgByLang.find(x => x.key == "M1946") ? arrMsgByLang.find(x => x.key == "M1946").value : reMsg_1;
            }

            if (userId == "") {
                alert(chkMsg_ID);
                return false;
            }
            if (userPwd == "") {
                alert(chkMsg_PWD);
                return false;
            }

            fetch("/Login.aspx/RegOtp", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ loginId: userId, userPwd: userPwd })
            })
                .then(response => {
                    if (!response.ok) {
                        alert("server error");
                    }

                    return response.json();
                })
                .then(result => {
                    let ret = result.d;
                    let arrMsg = ret.msg.split("|");

                    if (arrMsg[0] == "X") {
                        alert(arrMsg[1]);
                    }
                    else if (arrMsg[0] == "N") {
                        alert(reMsg_1);
                    }
                    else if (arrMsg[0] == "Y") {
                        let otpUserKey = ret.data1;
                        let otpQrImgUrl = ret.data2;

                        $("#hdOtpUserKey").val(otpUserKey);
                        $("#imgOtpQr").attr("src", otpQrImgUrl);
                        $("#imgOtpQr").show();
                        $("#divOtpReg").show();
                    }
                })
                .catch(error => {
                    alert("error occurred:" + error);
                });
        }

        // 비밀번호 보기 토글 (누르고 있는 동안만 표시)
        document.addEventListener("DOMContentLoaded", function () {
            const passwordInput = document.getElementById('txtPWD');
            const toggleBtn = document.getElementById('toggleBtn');
            const eyeIcon = document.getElementById('eyeIcon');

            // 눈 감은 모양 SVG 패스 (누르고 있을 때)
            const eyeOffPath = '<line x1="1" y1="1" x2="23" y2="23"></line><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';

            // 기본 눈 모양 SVG 패스 (뗐을 때)
            const eyeOnPath = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>';

            if (passwordInput && toggleBtn) {
                function showPassword() {
                    passwordInput.type = 'text';
                    eyeIcon.innerHTML = eyeOffPath;
                }

                function hidePassword() {
                    passwordInput.type = 'password';
                    eyeIcon.innerHTML = eyeOnPath;
                }

                // PC
                toggleBtn.addEventListener('mousedown', showPassword);
                toggleBtn.addEventListener('mouseup', hidePassword);
                toggleBtn.addEventListener('mouseleave', hidePassword);

                // 모바일
                toggleBtn.addEventListener('touchstart', function (e) {
                    e.preventDefault();
                    showPassword();
                });
                toggleBtn.addEventListener('touchend', hidePassword);
            }
        });
    </script>
</head>
<body>
    <%-- 우측 배경 슬라이드 : li 를 추가/삭제하면 슬라이드 수가 바뀐다. 문구는 figcaption 에서 수정 --%>
    <div class="bg_section">
        <ul class="login_bg">
            <li class="on">
                <img src='/Images/Login_New_Images/login_slide1.jpg?v=<%#nowYMDHM %>' alt='main background 1' />
                <figcaption>
                    <strong>최고의 품질로 고객의 신뢰에 보답합니다</strong>
                    <span>SEOYON E-HWA Quality Management System</span>
                </figcaption>
            </li>
            <li>
                <img src='/Images/Login_New_Images/login_slide2.jpg?v=<%#nowYMDHM %>' alt='main background 2' />
                <figcaption>
                    <strong>함께 설계하고, 함께 검증합니다</strong>
                    <span>협업과 데이터로 완성하는 품질 엔지니어링</span>
                </figcaption>
            </li>
            <li>
                <img src='/Images/Login_New_Images/login_slide3.jpg?v=<%#nowYMDHM %>' alt='main background 3' />
                <figcaption>
                    <strong>현장에서 출하까지, 하나로 연결된 스마트 품질관리</strong>
                    <span>AI · 데이터 기반 통합 품질 플랫폼</span>
                </figcaption>
            </li>
        </ul>
        <div class="login_bg_dots"></div>
    </div>

    <!--로그인-->
    <form id="Form1" runat="server" autocomplete="off" class="login_cont">
        <asp:HiddenField id="hReferer" runat="server"/>
        <input type="hidden" id="hidIsMobile" runat="server" />
        <input type="hidden" id="hdAppClientCd" runat="server" />
        <input type="hidden" id="hdUseOtp" runat="server" />
        <input type="hidden" id="hdUserType" runat="server" />
        <input type="hidden" id="hdOtpUserKey" runat="server" />
        <input type="hidden" id="hidFromGW" runat="server" />
        <fieldset>
            <legend id="loginCi" runat="server"></legend>
            <span class="sublogo" id="loginSubTitle" runat="server">QMS LOGIN</span>
            <span id="loginInfo_id" class="login_input id">
                <label for="txtID" class="alternate">Enter your ID</label>
                <input type="text" id="txtID" name="txtID" runat="server" placeholder="Enter your ID" onchange="fnIdChange();" />
            </span>
            <span id="loginInfo_pwd" class="login_input pw password-container">
                <label for="txtPWD" class="alternate">Enter your Password</label>
                <input type="password" id="txtPWD" name="txtPWD" runat="server" placeholder="Enter your Password" onchange="fnPwdChange();" onkeyup="EnterCheck();" />
                <!-- 비밀번호 보기 토글 버튼 -->
                <span id="toggleBtn" class="pwd-toggle-btn">
                    <svg id="eyeIcon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                </span>
            </span>
            <span id="loginInfo_otp" class="login_input otp" style="display:none;">
                <label for="txtOtp" class="alternate">Enter your OTP</label>
                <input type="text" id="txtOtp" name="txtOtp" runat="server" placeholder="Enter your OTP" />
            </span>
            <span class="login_input lang">
                <label for="cboCountry" class="alternate">select a language</label>
                <select id="cboCountry" class="dropdown" runat="server" onchange="fnCboCountryChange();">
                </select>
            </span>
            <button type="submit" id="btnLogin" runat="server" onclick="if(!LoginCheck(event)) return false;">Log-in</button>
            <div class="login_opt">
                <input type="checkbox" id="idSaveCheck"/>
                <label for="idSaveCheck">Save ID</label>
                <div id="btnOtpRegView" style="display:none;" onclick="fnOtpReg();">OTP Register</div>
            </div>
            <div class="notice">
                <p>시스템 정보는 당사 업무처리 이외의 사용 및 외부 유출을 금하며, 당사의 승인없이 정보 유출 시 법적 제재를 받을 수 있습니다.</p>
            </div>
            <footer runat="server" class="copyright" id="appCopyright">ⓒ 2026 SOLVA ALL RIGHTS RESERVED.</footer>
        </fieldset>
    </form>
</body>
</html>
