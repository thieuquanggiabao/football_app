Bạn là một chuyên gia Full-stack Developer chuyên về Flutter, Node.js (Express), Supabase và tích hợp cổng thanh toán (PayOS).

# BỐI CẢNH DỰ ÁN (CONTEXT)
Tôi đang xây dựng một ứng dụng xem bóng đá trực tiếp (Mobile App bằng Flutter) có tính năng mua gói cước Premium.
- Backend: Node.js chạy trên Render, xử lý tạo link thanh toán qua PayOS và nhận Webhook.
- Database: Supabase (PostgreSQL).
- Cổng thanh toán: PayOS (chuyển khoản VietQR).

# SỰ THAY ĐỔI KIẾN TRÚC (MỚI NHẤT)
Trước đây, tôi lưu thông tin gói cước (subscription) vào `user_metadata` của bảng `auth.users`. Hiện tại, tôi đã chuyển sang kiến trúc chuẩn: tạo bảng `public.profiles` để lưu thông tin user và bảng `public.transactions` để lưu lịch sử giao dịch.

Cấu trúc DB mới (đã chạy trên Supabase):
1. Bảng `profiles`: id (UUID), full_name, avatar_url, is_premium (boolean), plan_code (text), unlocked_leagues (text[] - ví dụ: ['PL', 'PD']), expire_date (timestamptz), premium_since (timestamptz). Đã có Trigger tự động thêm dòng mới khi user đăng ký.
2. Bảng `transactions`: id, user_id, order_id (text), amount (int), status ('pending', 'success', 'failed'), created_at, updated_at.

Các gói cước hiện có:
- NHA_PRO: giải ['PL'], 30 ngày. Chuyển thành 1 năm
- LALIGA_PRO: giải ['PD'], 30 ngày. Chuyển thành 1 năm
- BUNDESLIGA_PRO: giải ['BL1'], 30 ngày. Chuyển thành 1 năm
- SERIA_PRO: giải ['SA'], 30 ngày. Chuyển thành 1 năm
- SUPER_PRO: giải ['PL', 'PD', 'BL1', 'SA', 'FL1'], 30 ngày. Chuyển thành 1 năm, superpro sẽ xem được tất cả các giải.
- 

# YÊU CẦU CÔNG VIỆC (TASKS)

Hãy giúp tôi viết/sửa code cho 2 phần sau dựa trên bối cảnh trên
