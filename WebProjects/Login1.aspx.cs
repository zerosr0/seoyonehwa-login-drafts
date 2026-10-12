using Solva.FrameWork20.Fw20_Base;
using Solva.FrameWork20.Fw20_DataBase;
using Solva.FrameWork20.Fw20_DefaultControls;
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;

namespace Solva.WebProjects
{
    /// <summary>
    /// 로그인 시안 1 : 좌측 로그인 카드 + 우측 배경 이미지 슬라이드
    /// - 화면 초기화(CI, 타이틀, 저작권)만 담당한다.
    /// - 로그인/OTP 처리 WebMethod(LoginProc, ChkUseOtp, RegOtp, RegOtpUserKey)는 Login.aspx 의 것을 그대로 호출한다.
    /// </summary>
    /// - BaseForm 은 세션 검사 예외 페이지가 "login.aspx" 로 고정되어 있어(FrameWork20 수정 금지) Page 를 직접 상속한다.
    public partial class Login1 : System.Web.UI.Page
    {
        protected string loginFail;
        protected static string nowYMDHM = "";       // 정적 리소스 캐시 방지용 (BaseForm.nowYMDHM 과 동일 용도)

        protected void Page_Load(object sender, System.EventArgs e)
        {
            nowYMDHM = DateTime.Now.ToString("yyyyMMddHHmm");

            this.InitRepRequest();
            this.InitRepData();
            if (!Page.IsPostBack)
            {
                this.InitOnlyControls();
                this.InitOnlyData();
                this.Page.DataBind();
                this.DocStepProcess();
                this.ShowData();

            }
        }

        #region Web Form 디자이너에서 생성한 코드
        override protected void OnInit(EventArgs e)
        {
            InitializeComponent();
            base.OnInit(e);
        }

        private void InitializeComponent()
        {

        }
        #endregion

        #region 화면 초기화
        #region InitRepRequest
        public void InitRepRequest()
        {
            bool isMobile = DeviceHelper.IsMobile(Request);
            ClientScript.RegisterHiddenField("hidIsMobile", isMobile.ToString());

            this.loginFail = Request["loginfail"];
        }
        #endregion

        #region InitRepData
        public void InitRepData()
        {
        }
        #endregion

        #region InitOnlyControls
        public void InitOnlyControls()
        {
            string appClientCd = ConfigurationManager.AppSettings["appClientCd"];

            if (appClientCd != null && appClientCd.ToUpper() != "CQMS")
            {
                headTitle.Text = appClientCd;
                loginSubTitle.InnerText = appClientCd + " QMS LOGIN";
                appCopyright.InnerText = "ⓒ " + DateTime.Now.Year + " " + appClientCd + " ALL RIGHTS RESERVED.";
            }

            hdAppClientCd.Value = appClientCd;
            lnkLoginCss.Href = "/CommonScripts/Css/Login1.css?v=" + nowYMDHM;

            if (appClientCd != null && appClientCd.ToUpper() != "CQMS")
            {
                Hashtable ht = new Hashtable();
                ht.Add("@P_CLIENT", appClientCd);
                ht.Add("@P_LANG_FG", "KOR");
                ht.Add("@P_CHG_MDFI", "");
                ht.Add("@P_CHG_PGM_ID", "Login");

                Hashtable htResult = ExecuteDataBase.ExecDataSetResult("QSYS1701010_SEL", ht);
                string strResult = htResult["spResult"].ToString();
                DataSet ds = (DataSet)htResult["spDs"];

                if (strResult != "OK")
                {
                    BaseMessageBox.MessageBoxB(this.Page, "Warning - " + strResult);
                }
                else
                {
                    DataRow drLoginCi = ds.Tables[1].AsEnumerable().Where(x => x.Field<string>("INI_CODE") == "LOGIN_CI").FirstOrDefault();

                    if (drLoginCi != null)
                    {
                        string loginCiUrl = drLoginCi["FLOC"].ToString();

                        if (!String.IsNullOrEmpty(loginCiUrl))
                        {
                            loginCi.Style.Remove("background");
                            loginCi.Style.Add("background", "url(" + loginCiUrl.Replace("~", "") + ") center center / contain no-repeat");
                        }
                    }
                }
            }
        }
        #endregion

        #region InitOnlyData
        public void InitOnlyData()
        {

        }
        #endregion

        #region DocStepProcess
        public void DocStepProcess()
        {

        }
        #endregion

        #region ShowData
        public void ShowData()
        {

        }
        #endregion
        #endregion

        public static class DeviceHelper
        {
            private static readonly Regex MobileRegex = new Regex(
                @"(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino",
                RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled
            );

            public static bool IsMobile(HttpRequest request)
            {
                string userAgent = request.UserAgent;
                if (string.IsNullOrEmpty(userAgent)) return false;

                return MobileRegex.IsMatch(userAgent);
            }
        }
    }
}
