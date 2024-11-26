#import "@preview/touying:0.5.3": *

/// Default slide function for the presentation.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let ucas-slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto, auto),
      row-gutter: 3mm,
      grid(
        rows: (auto, auto),
        utils.call-or-display(self, self.store.navigation),
        utils.call-or-display(self, self.store.header),
      ),
      block(
        inset: (x: .5em),
        components.left-and-right(
          text(
            fill: self.colors.primary,
            weight: "bold",
            size: 1.2em,
            utils.call-or-display(self, self.store.header),
          ),
          text(
            fill: self.colors.primary.lighten(65%),
            none,
          ),
        ),
      ),
    )
  }
  let footer(self) = {
    set align(center + bottom)
    set text(size: .4em)
    let cell(..args, it) = components.cell(
      ..args,
      inset: 1mm,
      align(horizon, text(fill: white, it)),
    )
    show: block.with(width: 100%, height: auto)
    let combined_footer_up = box[
      #grid(
        columns: (1fr, 1fr),
        align(left, utils.call-or-display(self, self.store.footer-up-left)),
        align(right, utils.call-or-display(self, self.store.footer-up-right)),
      )
    ]
    context {
      let nth_slide = [#utils.slide-counter.get().first() / #utils.last-slide-number]
      let combined_footer_down = cell[
        #align(left, utils.call-or-display(self, self.store.footer-down-left))
        #align(right, nth_slide)
      ]
      let combined_footer_down = box[
        #grid(
          columns: (1fr, 1fr),
          align(left, utils.call-or-display(self, self.store.footer-down-left)),
          align(right, nth_slide),
        )
      ]
      {
        grid(
          rows: self.store.footer-rows,
          cell(
            fill: self.colors.secondary,
            utils.call-or-display(self, combined_footer_up),
          ),
          cell(
            fill: self.colors.primary,
            utils.call-or-display(self, combined_footer_down),
          ),
        )
      }
    }
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - `extra` is the extra information of the slide. You can pass the extra information to the `title-slide` function.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let body = {
    if info.logo != none {
      block(
        fill: white,
        inset: 0pt,
        outset: 0pt,
        grid(
          align: center + horizon,
          columns: (1fr, auto),
          rows: 1.6em,
          gutter: 0em,
          [],
          align(
            right,
            block(
              fill: white,
              inset: 4pt,
              height: 100%,
              text(fill: white, info.logo),
            ),
          ),
        ),
      )
    }
    align(
      center + horizon,
      {
        block(
          inset: 1em,
          breakable: false,
          {
            text(size: 2em, fill: self.colors.primary, strong(info.title))
            if info.subtitle != none {
              parbreak()
              text(size: 1.2em, fill: self.colors.primary, info.subtitle)
            }
          },
        )
        set text(size: .8em)
        grid(
          columns: (1fr,) * calc.min(info.authors.len(), 3),
          column-gutter: 1em,
          row-gutter: 1em,
          ..info.authors.map(author => text(
            fill: self.colors.neutral-darkest,
            author,
          ))
        )
        v(1em)
        if info.institution != none {
          parbreak()
          text(size: .9em, info.institution)
        }
        if info.date != none {
          parbreak()
          text(size: .8em, utils.display-info-date(self))
        }
      },
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, body)
})



/// Modern beamer theme for ucas students built with Typst.
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `progress-bar` is where to show the progress bar. Default is `true`.
///
/// - `header` is the header of the slides. Default is `utils.display-current-heading()`
///
/// - `footer-rows` is the rows of the footer. Default is `(1fr, 1fr)`.
///
/// - `footer-up` is the upper part of the footer. Default is `self.info.author-institute`.
/// - `footer-down` is the lower part of the footer. Default is `self.info.short-title`.
#let ucas-beamer-theme(
  aspect-ratio: "16-9",
  progress-bar: true,
  header: utils.display-current-heading(level: 2),
  header-right: self => self.info.logo,
  footer-rows: (1fr, 1fr),
  footer-up-left: self => self.info.author,
  footer-up-right: self => self.info.institution,
  footer-down-left: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 2em),
    ),
    config-common(
      slide-fn: ucas-slide,
      // new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(fill: self.colors.neutral-darkest, size: 25pt)
        show heading: set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#04194a"),
      secondary: rgb("#2f5c98"),
      tertiary: rgb("#448C95"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    config-store(
      progress-bar: progress-bar,
      header: header,
      navigation: self => components.simple-navigation(
        self: self,
        primary: self.colors.primary,
        secondary: gray,
        background: self.colors.neutral-lightest,
        logo: utils.call-or-display(self, header-right),
      ),
      footer-rows: footer-rows,
      footer-up-left: footer-up-left,
      footer-up-right: footer-up-right,
      footer-down-left: footer-down-left,
    ),
    ..args,
  )
  body
}



