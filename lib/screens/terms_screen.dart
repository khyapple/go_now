import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          '이용약관',
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
            _buildSection(
              '제1조 (목적)',
              '본 약관은 Go Now(이하 "회사")가 제공하는 일정 관리 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
            ),
            _buildSection(
              '제2조 (정의)',
              '1. "서비스"란 회사가 제공하는 일정 관리, 알림 등 모든 서비스를 의미합니다.\n\n2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 이용하는 자를 말합니다.\n\n3. "계정"이란 이용자가 서비스를 이용하기 위하여 회사에 등록한 정보를 말합니다.',
            ),
            _buildSection(
              '제3조 (약관의 게시와 개정)',
              '1. 회사는 본 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 내에 게시합니다.\n\n2. 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 개정할 수 있습니다.\n\n3. 회사가 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 서비스 내에 그 적용일자 7일 전부터 적용일자 전일까지 공지합니다.',
            ),
            _buildSection(
              '제4조 (서비스의 제공)',
              '1. 회사는 다음과 같은 서비스를 제공합니다:\n   - 일정 등록, 수정, 삭제\n   - 일정 알림\n   - 경로 안내\n   - 기타 부가 서비스\n\n2. 회사는 서비스의 원활한 제공을 위해 시스템 정기점검, 증설 및 교체를 위해 서비스를 일시 중단할 수 있습니다.',
            ),
            _buildSection(
              '제5조 (서비스의 변경 및 중단)',
              '1. 회사는 상당한 이유가 있는 경우 운영상, 기술상의 필요에 따라 제공하고 있는 서비스의 전부 또는 일부를 변경할 수 있습니다.\n\n2. 회사는 무료로 제공되는 서비스의 일부 또는 전부를 회사의 정책 및 운영의 필요상 수정, 중단, 변경할 수 있으며, 이에 대하여 관련법에 특별한 규정이 없는 한 이용자에게 별도의 보상을 하지 않습니다.',
            ),
            _buildSection(
              '제6조 (이용자의 의무)',
              '1. 이용자는 다음 행위를 하여서는 안 됩니다:\n   - 회사의 서비스 정보를 이용하여 얻은 정보를 회사의 사전 승낙 없이 복제 또는 유통시키거나 상업적으로 이용하는 행위\n   - 타인의 명예를 손상시키거나 불이익을 주는 행위\n   - 회사의 저작권, 제3자의 저작권 등 기타 권리를 침해하는 행위\n   - 공공질서 및 미풍양속에 위반되는 내용의 정보, 문장, 도형, 음향, 동영상을 전송, 게시, 전자우편 또는 기타의 방법으로 타인에게 유포하는 행위',
            ),
            _buildSection(
              '제7조 (저작권의 귀속)',
              '1. 회사가 작성한 저작물에 대한 저작권 기타 지적재산권은 회사에 귀속합니다.\n\n2. 이용자는 회사의 서비스를 이용함으로써 얻은 정보 중 회사에게 지적재산권이 귀속된 정보를 회사의 사전 승낙 없이 복제, 송신, 출판, 배포, 방송 기타 방법에 의하여 영리목적으로 이용하거나 제3자에게 이용하게 하여서는 안됩니다.',
            ),
            _buildSection(
              '제8조 (면책조항)',
              '1. 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n\n2. 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.\n\n3. 회사는 이용자가 서비스를 이용하여 기대하는 수익을 상실한 것에 대하여 책임을 지지 않으며, 그 밖에 서비스를 통하여 얻은 자료로 인한 손해에 관하여 책임을 지지 않습니다.',
            ),
            const SizedBox(height: 20),
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
                    '부칙',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '본 약관은 2026년 1월 1일부터 시행됩니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
