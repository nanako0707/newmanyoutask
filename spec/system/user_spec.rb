require 'rails_helper'
RSpec.describe 'ユーザ登録・ログイン・ログアウト機能', type: :system do
  describe 'ユーザ登録のテスト' do
    context 'ユーザのデータなくログインいていない場合' do
      it 'ユーザ新規登録のテスト' do
        visit new_user_path
        fill_in 'user[name]', with: 'sample'
        fill_in 'user[email]', with: 'sample@example.com'
        fill_in 'user[password]', with: '000000'
        fill_in 'user[password_confirmation]', with: '000000'
        click_on '登録する'
        # 現在のパスがユーザid:1のパスと等しいか
        expect(page).to have_content 'sample'
        # expect(current_path).to eq user_path(id: 1)
      end
      it 'ログインしていない時はログイン画面に飛ぶテスト' do
        visit tasks_path
        expect(current_path).to eq new_session_path
      end
    end
  end

  describe "セッション機能のテスト" do
    before do
      @user = create(:user)
    end
    context "ユーザのデータがあってログインしていない場合" do
      it "ログインできること" do
        visit new_session_path
        fill_in 'session_email', with: @user.email
        fill_in 'session_password', with: @user.password
        click_button (I18n.t('view.login'))
        expect(current_path).to eq user_path(id: @user.id)
      end
    end

    context "ユーザのデータがあってログインしている場合" do
      before do
        visit new_session_path
        fill_in "session_email", with: "sample@example.com"
        fill_in "session_password", with: "000000"
        click_button (I18n.t('view.login'))
      end

      it "自分の詳細画面（マイページ）に飛べること" do
        visit user_path(id: @user.id)
        expect(current_path).to eq user_path(id: @user.id)
      end

      it "一般ユーザが他人の詳細画面に飛ぶとタスク一覧ページに遷移すること" do
        @admin_user = FactoryBot.create(:admin_user)
        visit user_path(id: @admin_user.id)
        expect(page).to have_content "権限がありません！"
      end

      it "ログアウトができること" do
        visit user_path(id: @user.id)
        click_link (I18n.t('view.logout'))
        expect(current_path).to eq new_session_path
        expect(page).to have_content "ログアウトしました！"
      end
    end
  end

  describe "管理画面のテスト" do
    context "アドミンユーザがない場合" do
      it "管理者は管理画面にアクセスできること" do
        create(:admin_user)
        visit new_session_path
        fill_in "session_email", with: "admin@example.com"
        fill_in "session_password", with: "000000"
        click_button (I18n.t('view.login'))
        visit admin_users_path
        expect(page).to have_content "管理画面"
      end
    end

    context "一般ユーザでログインしている場合" do
      it "一般ユーザは管理画面にアクセスできないこと" do
        FactoryBot.create(:user)
        visit new_session_path
        fill_in "session_email", with: "sample@example.com"
        fill_in "session_password", with: "000000"
        click_button (I18n.t('view.login'))
        visit admin_users_path
        expect(page).to have_content "あなたは管理者ではありません！"
      end
    end

    context "管理者でログインしている場合" do
      before do
        create(:admin_user)
        visit new_session_path
        fill_in "session_email", with: "admin@example.com"
        fill_in "session_password", with: "000000"
        click_button (I18n.t('view.login'))
        visit admin_users_path
      end

      it "管理者はユーザを新規登録できること" do
        click_on "ユーザを作成する"
        fill_in "user_name", with: "111"
        fill_in "user_email", with: "111@example.com"
        fill_in "user_password", with: "111111"
        fill_in "user_password_confirmation", with: "111111"
        click_on '登録する'
        expect(page).to have_content "111"
      end

      it "管理者はユーザ詳細画面にアクセスできること" do
        @user = create(:user)
        visit admin_user_path(id: @user.id)
        expect(page).to have_content "sample"
      end

      it "管理者はユーザの編集画面からユーザを編集できること" do
        @user = create(:user)
        visit edit_admin_user_path(id: @user.id)
        fill_in 'user_name', with: 'sample2'
        fill_in 'user_email', with: 'sample2@example.com'
        fill_in 'user_password', with: '111111'
        fill_in 'user_password_confirmation', with: '111111'
        click_on '更新する'
        expect(page).to have_content "sample2"
      end

      it "管理者はユーザの削除をできること" do
        @user = create(:user)
        visit admin_users_path
        click_on "ユーザを削除する", match: :first
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content "ユーザを削除しました！"
      end
    end
  end
end
