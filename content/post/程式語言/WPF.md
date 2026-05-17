C# 命名方法
Button.Text 物件中文名稱
Button.Name 物件變數
Label：單行不能換行唯獨文字
TextBlock:多行唯獨文字外觀豐富

設定`app.manifest`
![gh|300](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1751965949000r5sd0p.png)

上傳Github
![gh|300](https://raw.githubusercontent.com/jafeeye/imglib/main/obsidian/1752819961000mqhvzw.png)

#### XAML介面
1. 結尾一定要有對應標籤
2. 在`<Window x:Class>` 中 ShowInTaskbar="True"
3. `<Window>` 標籤可以寫入 `FontFamily="Microsoft JhengHei" FontSize="14"`
4. `<ContextMenu x:Key="NotifyIconMenu" FontFamily="Microsoft JhengHei" FontSize="14">`
5. `<ContextMenu>` 是無法繼承`<Window>`（屬Popup)，要明確指定字體樣式
6. Grid可以有多個分配版面，快速自訂控件就是先畫一個Grid，Grid自訂欄位分配大小，之後再寫按鈕，控件為0編號
```
<Grid>
</Grid>
```



MainWindow裡面的InitializeComponent();

![[Pasted image 20241121230118.png|300x250]]

#### 錯誤排除
1. 出現`($(MsBuildMajorVersion) < 16)`... 錯誤：在`.csproj` 直接指定編譯版本
```
<PropertyGroup>
  <MsBuildMajorVersion>16</MsBuildMajorVersion>
</PropertyGroup>
```
2. 大小寫有沒有打錯
3. 像System.Drawing報錯是因為版本不對，當套件有引用功能卻異常一定要檢查版本是否太高過低相容
4. 在`方案XXX專案` 項目下面點兩下可以顯示csproj內容
5. 當一個專案包含太多專案，按右鍵設為啟動專案才能執行
6. net雖然跨平台但是也要跨平台編譯，只有Electron跟tauri 可以單平台編譯跨平台
7. Avalonia 在macOS 可使用Rider開發
8. INotifyPropertyChanged

<Image 語法 />：單行寫法最後一定是/> 結尾
工具/Nuget套件管理員/套件管理員主控台，會出現套件管理器主控台，輸入PM>Install-Package MahApps.Metro.IconPacks.Material -Version 4.11.0
xmlns 其實是在xml格式中，聲明或引用命名空間（Namespace）的方式
BasedOn 類繼承的層次結構來組織他們的樣式
快速打法
Alt+Enter
注意加減符號是否有打錯 += -=
在WPF上似乎有人談論設定起始焦點的困難(WPF Initial Focus Nightmare)

**MVVM用法**

![[Pasted image 20241121230100.png]]


WinForms 加入DPI
1. Program.cs
```
namespace YourNamespace
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            // ✅ 高 DPI 模式設定（.NET Framework 4.7+ / .NET Core / .NET 5+）
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.SetHighDpiMode(HighDpiMode.PerMonitorV2); // 推薦 PerMonitorV2 模式

            Application.Run(new Form1());
        }
    }
}
```

2. Form1.cs
```
public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
        this.AutoScaleMode = AutoScaleMode.Dpi; // ✅ 根據螢幕 DPI 縮放
    }
}

```

3. app.manifest
```
<application xmlns="urn:schemas-microsoft-com:asm.v3">
  <windowsSettings>
    <!-- 將這段取消註解 -->
    <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true/pm</dpiAware>
  </windowsSettings>
</application>
```


### 不同事件
DragDrop：托放事件

**C#常用寫法**
try...catch為程式除錯寫法
```csharp
try
{
    string content = File.ReadAllText("不存在.txt");
}
catch (FileNotFoundException ex)
{
    Console.WriteLine("找不到檔案：" + ex.Message);
    // 不會崩潰，程式繼續執行
}
```
