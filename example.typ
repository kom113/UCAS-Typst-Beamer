#import "@preview/touying:0.5.3": *
#import "./template.typ": *

#show: ucas-beamer-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: "这是主标题",                                 // 主标题
    subtitle: "这是副标题",                              // 副标题
    author: "张三",                                     // 汇报人
    date: datetime.today(),                            // 时间，需要自定义的话可以改成任何字符串，例如"1949-10-01"
    institution: "中国科学院XXXX研究所/学院",            // 单位
    logo: image("assets/ucas_logo.svg", width: 30%),   // 单位logo
  ),
)

#title-slide()                                         // 生成标题页，如果不需要可以去掉这一行

#ucas-slide(composer: (1fr, 1fr))[
  = 双栏排版
][= 双栏排版]

#ucas-slide(composer: (1fr, 1fr, 1fr))[
  = 双栏排版
][= 双栏排版][
  = 当然也可以有更多栏
]

#ucas-slide[
  = 无序列表
  - 1
  - 2
  - 3
]

#ucas-slide[
  = 插入图片
  #image("./assets/ucas_logo.svg", width: 80%)
]
