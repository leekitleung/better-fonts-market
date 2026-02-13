# 贡献指南

感谢你有兴趣为 Better Fonts Market 贡献字体！这份指南会帮助你顺利完成提交。

## 收录标准

我们只收录满足以下条件的字体：

- **免费可商用**：许可证为 OFL、Apache 2.0、MIT、GPL、公共领域等开源协议
- **原创或已获授权**：你是字体作者，或字体以开源协议公开发布
- **格式正确**：`.ttf` `.otf` `.ttc` `.woff` `.woff2`
- **可正常使用**：字体文件未损坏，能被操作系统正常识别

以下字体不会被收录：

- 商业字体（方正、汉仪、蒙纳等付费字体）
- 破解或去除 DRM 的字体
- 来源不明、无法确认许可证的字体
- 仅限个人使用的字体

## 提交流程

### 1. Fork 并克隆

```bash
git clone https://github.com/<你的用户名>/better-fonts-market.git
cd better-fonts-market
```

### 2. 添加字体文件

创建一个以字体名称命名的文件夹，将字体文件放入其中：

```
better-fonts-market/
└── SmileySans/
    ├── SmileySans-Regular.ttf
    ├── SmileySans-Bold.ttf    # 如有多字重
    └── LICENSE                # 强烈建议附带许可证文件
```

### 命名规范 (重要 ⚠️)

为了避免在插件中显示乱码或冗余标签（如 `[MianFei]`），请严格遵守：

- **文件夹命名**：必须使用**纯英文/拼音**，不包含空格或特殊字符。
  - ✅ 推荐：`SmileySans` / `XiaWuWenKai` / `MaokenAssortedSans`
  - ❌ 禁止：`[免费]得意黑` / `站酷 快乐体` / `[MianFei]CangJiGaoDe`
- **字体文件**：建议保持原始文件名，或重命名为英文。
- **单一原则**：一个文件夹只存放一个字体家族（及其不同字重）。

### 3. 提交 PR

```bash
git checkout -b add-font-你的字体名
git add .
git commit -m "add: 你的字体名称"
git push origin add-font-你的字体名
```

然后在 GitHub 上创建 Pull Request，描述中请包含：

- **字体名称**
- **作者/来源**：字体的原始作者或发布页面链接
- **许可证类型**：OFL / Apache 2.0 / MIT / GPL / 公共领域
- **简要说明**（可选）：字体的特点、适用场景等

### 4. 等待合并

维护者会审核你的 PR，确认许可证合规后合并。合并后 GitHub Actions 会自动：

1. 扫描新增的字体文件
2. 更新 `manifest.json`
3. 将大文件（≥ 20MB）上传至 GitHub Releases
4. 字体立即可在 FontLens 插件中使用

## PR 描述模板

```markdown
## 新增字体

- 字体名称：
- 作者：
- 许可证：OFL / Apache 2.0 / MIT / GPL / 公共领域
- 来源链接：
- 字重数量：
- 格式：TTF / OTF

### 备注（可选）

简要描述字体特点。
```

## 常见问题

**Q: 同一个字体有 TTF 和 OTF 两种格式，应该提交哪个？**

优先提交 OTF。如果两种格式都有且你认为都有价值，可以都放进来，插件端会自动去重只显示一个预览。

**Q: 字体文件很大（超过 20MB），可以提交吗？**

可以。CI 会自动将大文件上传至 GitHub Releases，不会影响仓库体积。

**Q: 我是字体作者，想提交自己的字体。**

非常欢迎！请在 PR 描述中注明你是作者，并确认许可证类型。

**Q: 我发现仓库中某个字体的许可证有问题。**

请提交 Issue 说明情况，我们会尽快核实并处理。
