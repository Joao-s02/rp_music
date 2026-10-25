#include "flutter_window.h"

#include <optional>
#include <shellapi.h>
#include <flutter/standard_method_codec.h>
#include "resource.h"
#pragma comment(lib, "shell32.lib")

namespace {
constexpr UINT kTrayMessage = WM_APP + 70;
constexpr UINT kFinishClose = WM_APP + 71;
constexpr UINT kShow = 41001;
constexpr UINT kTogglePlayback = 41002;
constexpr UINT kQuit = 41003;
}

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  desktop_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "rp_music/desktop",
      &flutter::StandardMethodCodec::GetInstance());
  desktop_channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    const auto& method = call.method_name();
    if (method == "initialize") {
      desktop_ready_ = true;
      result->Success(flutter::EncodableValue(AddTrayIcon()));
    } else if (method == "hide") {
      if (!tray_visible_ && !AddTrayIcon()) {
        result->Error("tray_unavailable", "No se pudo crear el icono de bandeja");
      } else { ShowWindow(GetHandle(), SW_HIDE); result->Success(); }
    } else if (method == "show") {
      ShowFromTray(); result->Success();
    } else if (method == "isVisible") {
      result->Success(flutter::EncodableValue(IsWindowVisible(GetHandle()) != FALSE));
    } else if (method == "finishClose") {
      result->Success(); PostMessage(GetHandle(), kFinishClose, 0, 0);
    } else if (method == "requestClose") {
      result->Success(); PostMessage(GetHandle(), WM_CLOSE, 0, 0);
    } else if (method == "dispose") {
      desktop_ready_ = false; RemoveTrayIcon(); result->Success();
    } else result->NotImplemented();
  });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  RemoveTrayIcon();
  desktop_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  static const UINT taskbar_created = RegisterWindowMessage(L"TaskbarCreated");
  if (message == taskbar_created && desktop_ready_) {
    tray_visible_ = false;
    if (!AddTrayIcon()) ShowFromTray();
    return 0;
  }
  if (message == kFinishClose) {
    allow_close_ = true; PostMessage(hwnd, WM_CLOSE, 0, 0); return 0;
  }
  if (message == WM_CLOSE && desktop_ready_ && !allow_close_) {
    SendDesktopEvent("closeRequested"); return 0;
  }
  if (message == kTrayMessage) {
    if (lparam == WM_LBUTTONUP || lparam == WM_LBUTTONDBLCLK) ShowFromTray();
    if (lparam == WM_RBUTTONUP || lparam == WM_CONTEXTMENU) {
      POINT point; GetCursorPos(&point);
      HMENU menu = CreatePopupMenu();
      AppendMenu(menu, MF_STRING, kShow, L"Abrir RP Music");
      AppendMenu(menu, MF_STRING, kTogglePlayback, L"Reproducir / Pausar");
      AppendMenu(menu, MF_SEPARATOR, 0, nullptr);
      AppendMenu(menu, MF_STRING, kQuit, L"Salir");
      SetForegroundWindow(hwnd);
      const UINT selected = TrackPopupMenu(menu, TPM_RETURNCMD | TPM_RIGHTBUTTON,
          point.x, point.y, 0, hwnd, nullptr);
      DestroyMenu(menu);
      PostMessage(hwnd, WM_NULL, 0, 0);
      if (selected == kShow) ShowFromTray();
      if (selected == kTogglePlayback) SendDesktopEvent("togglePlayback");
      if (selected == kQuit) SendDesktopEvent("quitRequested");
    }
    return 0;
  }
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

bool FlutterWindow::AddTrayIcon() {
  tray_window_ = GetHandle();
  NOTIFYICONDATA data{}; data.cbSize = sizeof(data); data.hWnd = tray_window_; data.uID = 1;
  data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP; data.uCallbackMessage = kTrayMessage;
  data.hIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  wcscpy_s(data.szTip, L"RP Music");
  tray_visible_ = Shell_NotifyIcon(tray_visible_ ? NIM_MODIFY : NIM_ADD, &data) != FALSE;
  return tray_visible_;
}

void FlutterWindow::RemoveTrayIcon() {
  if (!tray_visible_) return;
  NOTIFYICONDATA data{}; data.cbSize = sizeof(data); data.hWnd = tray_window_; data.uID = 1;
  Shell_NotifyIcon(NIM_DELETE, &data); tray_visible_ = false;
}

void FlutterWindow::ShowFromTray() {
  ShowWindow(GetHandle(), SW_RESTORE); SetForegroundWindow(GetHandle());
}

void FlutterWindow::SendDesktopEvent(const char* event) {
  if (desktop_channel_) desktop_channel_->InvokeMethod(event, nullptr);
}
