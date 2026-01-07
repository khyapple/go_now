import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '개인정보 처리방침',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개인정보 처리방침',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go Now는 이용자의 개인정보를 중요시하며, 개인정보보호법을 준수하고 있습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '제1조 (개인정보의 수집 및 이용 목적)',
              'Go Now는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 개인정보보호법에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.\n\n1. 회원 가입 및 관리\n   - 회원 가입 의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증\n\n2. 서비스 제공\n   - 일정 관리 서비스 제공\n   - 알림 서비스 제공\n   - 경로 안내 서비스 제공',
            ),
            _buildSection(
              '제2조 (수집하는 개인정보 항목)',
              'Go Now는 다음의 개인정보 항목을 처리하고 있습니다.\n\n1. 필수 항목\n   - 이메일 주소\n   - 비밀번호 (암호화 저장)\n\n2. 선택 항목\n   - 프로필 사진\n   - 알림 설정 정보\n\n3. 자동 수집 항목\n   - 서비스 이용 기록\n   - 접속 로그\n   - 기기 정보',
            ),
            _buildSection(
              '제3조 (개인정보의 처리 및 보유 기간)',
              '1. Go Now는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n\n2. 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다:\n   - 회원 가입 및 관리: 회원 탈퇴 시까지\n   - 서비스 제공: 서비스 이용 종료 시까지',
            ),
            _buildSection(
              '제4조 (개인정보의 제3자 제공)',
              'Go Now는 정보주체의 개인정보를 제1조(개인정보의 수집 및 이용 목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보보호법 제17조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.',
            ),
            _buildSection(
              '제5조 (개인정보의 파기)',
              '1. Go Now는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n\n2. 파기 절차 및 방법은 다음과 같습니다:\n   - 파기 절차: 불필요한 개인정보는 내부 방침에 따라 즉시 파기\n   - 파기 방법: 전자적 파일 형태는 복구 불가능한 방법으로 영구 삭제',
            ),
            _buildSection(
              '제6조 (정보주체의 권리·의무)',
              '1. 정보주체는 Go Now에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다:\n   - 개인정보 열람 요구\n   - 오류 등이 있을 경우 정정 요구\n   - 삭제 요구\n   - 처리정지 요구\n\n2. 제1항에 따른 권리 행사는 Go Now에 대해 서면, 전화, 전자우편 등을 통하여 하실 수 있으며 Go Now는 이에 대해 지체없이 조치하겠습니다.',
            ),
            _buildSection(
              '제7조 (개인정보의 안전성 확보 조치)',
              'Go Now는 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다:\n\n1. 관리적 조치: 내부관리계획 수립·시행\n2. 기술적 조치: 개인정보처리시스템 등의 접근권한 관리, 접근통제시스템 설치, 고유식별정보 등의 암호화\n3. 물리적 조치: 전산실, 자료보관실 등의 접근통제',
            ),
            _buildSection(
              '제8조 (개인정보 보호책임자)',
              '1. Go Now는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n▶ 개인정보 보호책임자\n   성명: 개인정보보호팀\n   연락처: privacy@gonow.app',
            ),
            _buildSection(
              '제9조 (개인정보 처리방침 변경)',
              '1. 이 개인정보 처리방침은 2026년 1월 1일부터 적용됩니다.\n\n2. 이전의 개인정보 처리방침은 아래에서 확인하실 수 있습니다.\n   - 이전 버전 없음 (최초 제정)',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '개인정보 침해에 대한 신고나 상담이 필요하신 경우에는 아래 기관에 문의하시기 바랍니다.\n\n- 개인정보침해신고센터 (privacy.kisa.or.kr / 국번없이 118)\n- 개인정보분쟁조정위원회 (www.kopico.go.kr / 1833-6972)\n- 대검찰청 사이버범죄수사단 (www.spo.go.kr / 국번없이 1301)\n- 경찰청 사이버안전국 (cyberbureau.police.go.kr / 국번없이 182)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
