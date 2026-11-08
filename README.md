# CemWinUtility (Windows Yardımcı Programı)

[![Version](https://img.shields.io/github/v/release/ChrisTitusTech/winutil?color=%230567ff&label=Latest%20Release&style=for-the-badge)](https://github.com/ChrisTitusTech/winutil/releases/latest)
![Downloads](https://img.shields.io/github/downloads/ChrisTitusTech/winutil/winutil.ps1?label=Total%20Downloads&style=for-the-badge)
[![Discord](https://dcbadge.limes.pink/api/server/https://discord.gg/RUbZUZyByQ?theme=default-inverted&style=for-the-badge)](https://discord.gg/RUbZUZyByQ)

Windows kurulumlarını kolaylaştırmak (**yüklemeler**), sistemi sadeleştirmek (**ince ayarlar**), sorunları gidermek (**yapılandırma**) ve **Windows güncellemelerini** yönetmek için özenle derlenmiş sistem görevleri koleksiyonu. Her yeni Windows kurulumunda temiz bir başlangıç için çalıştırın.

![Title Screen](docs/src/assets/branding/title-screen.png)


---

## Hızlı Başlangıç

> **CemWinUtility, sistem genelinde değişiklikler gerçekleştirdiği için Yönetici olarak çalıştırılmalıdır.**

PowerShell veya Terminal'i yönetici olarak açın ve çalıştırın:

**Kararlı Sürüm (Önerilen)**
```ps1
irm https://christitus.com/win | iex
```

**Geliştirici Sürümü**
```ps1
irm https://christitus.com/windev | iex
```

### Yönetici Terminali Nasıl Açılır?

- **Başlat menüsü:** Başlat'a sağ tıklayın → *Windows PowerShell (Yönetici)* veya *Terminal (Yönetici)*
- **Arama:** `Windows tuşuna` basın, `PowerShell` veya `Terminal` yazın, ardından `Ctrl + Shift + Enter` tuşlarına basın

---

## Otomasyon / Ön Ayarlar (Presets)

Manuel seçim yapmadan önceden tanımlanmış bir yapılandırmayı uygulayın:

```powershell
& ([ScriptBlock]::Create((irm https://christitus.com/win))) -Preset Standard
```

| Ön Ayar | Açıklama |
|---------|----------|
| `Standard` | Çoğu kullanıcı için dengeli varsayılanlar |
| `Minimal` | Her kullanıcıya uygun minimum değişiklikler |
| `Advanced` | İleri düzey kullanıcılar için derinlemesine ince ayarlar |

Her bir ön ayarın tam olarak ne yaptığını görmek için:
https://github.com/ChrisTitusTech/winutil/blob/main/config/preset.json

---

## Derleme ve Geliştirme

Bkz: https://github.com/ChrisTitusTech/winutil/blob/main/.github/CONTRIBUTING.md

---

## Kaynaklar

- [Resmi Dokümantasyon](https://winutil.christitus.com/)
- [YouTube Eğitim Videosu](https://www.youtube.com/watch?v=6UQZ5oQg8XA)
- [ChrisTitus.com Makalesi](https://christitus.com/windows-tool/)
- [Bilinen Sorunlar](https://winutil.christitus.com/knownissues/)
- [Hata Bildir](https://github.com/ChrisTitusTech/winutil/issues)

---

## Destek

- Destek olmak için bir ⭐ bırakın! 😊
- Daha hızlı Dotnet sürümü burada satışta: https://www.cttstore.com/windows-toolbox

## Sponsorlar

Bu projeyi aylık katkılarıyla canlı tutan sponsorlarımız.

<!-- sponsors --><a href="https://github.com/dwelfusius"><img src="https:&#x2F;&#x2F;github.com&#x2F;dwelfusius.png" width="60px" alt="User avatar: " /></a><a href="https://github.com/mews-se"><img src="https:&#x2F;&#x2F;github.com&#x2F;mews-se.png" width="60px" alt="User avatar: Martin" /></a><a href="https://github.com/jdiegmueller"><img src="https:&#x2F;&#x2F;github.com&#x2F;jdiegmueller.png" width="60px" alt="User avatar: Jason A. Diegmueller" /></a><a href="https://github.com/robertsandrock"><img src="https:&#x2F;&#x2F;github.com&#x2F;robertsandrock.png" width="60px" alt="User avatar: RMS" /></a><a href="https://github.com/paulsheets"><img src="https:&#x2F;&#x2F;github.com&#x2F;paulsheets.png" width="60px" alt="User avatar: Paul" /></a><a href="https://github.com/djones369"><img src="https:&#x2F;&#x2F;github.com&#x2F;djones369.png" width="60px" alt="User avatar: Dave J  (WhamGeek)" /></a><a href="https://github.com/anthonymendez"><img src="https:&#x2F;&#x2F;github.com&#x2F;anthonymendez.png" width="60px" alt="User avatar: Anthony Mendez" /></a><a href="https://github.com/FatBastard0"><img src="https:&#x2F;&#x2F;github.com&#x2F;FatBastard0.png" width="60px" alt="User avatar: " /></a><a href="https://github.com/DursleyGuy"><img src="https:&#x2F;&#x2F;github.com&#x2F;DursleyGuy.png" width="60px" alt="User avatar: DursleyGuy" /></a><a href="https://github.com/DwayneTheRockLobster1"><img src="https:&#x2F;&#x2F;github.com&#x2F;DwayneTheRockLobster1.png" width="60px" alt="User avatar: " /></a><a href="https://github.com/KieraKujisawa"><img src="https:&#x2F;&#x2F;github.com&#x2F;KieraKujisawa.png" width="60px" alt="User avatar: Kiera Meredith" /></a><a href="https://github.com/seanh1995"><img src="https:&#x2F;&#x2F;github.com&#x2F;seanh1995.png" width="60px" alt="User avatar: Sean (ANGRYxScotsman)" /></a><a href="https://github.com/josencarnacao"><img src="https:&#x2F;&#x2F;github.com&#x2F;josencarnacao.png" width="60px" alt="User avatar: José Encarnação" /></a><!-- sponsors -->

*<sub>Aboneliği devam eden sponsorlar ayrıca .NET alternatifine de erişebilir.</sub>

---

## Katkıda Bulunanlar

[![Contributors](https://contrib.rocks/image?repo=ChrisTitusTech/winutil)](https://github.com/ChrisTitusTech/winutil/graphs/contributors)

Bu projeye zaman ve emek ayıran herkese teşekkürler. Harika iş çıkarmaya devam edin 🍻
