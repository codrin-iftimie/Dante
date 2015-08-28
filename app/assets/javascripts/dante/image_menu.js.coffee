utils = Dante.utils

class Dante.Editor.ImageMenu extends Dante.View

  events:
    "mousedown li" : "handleClick"

  initialize: (opts={})=>
    @config = opts.buttons || @default_config()
    @current_editor = opts.editor

    @commandsReg = {
      block: /^(?:p|h[1-6]|blockquote|pre)$/
      inline: /^(?:bold|italic|underline|insertorderedlist|insertunorderedlist|indent|outdent)$/,
      source: /^(?:insertimage|createlink|unlink)$/
      insert: /^(?:inserthorizontalrule|insert)$/
      wrap: /^(?:code)$/
    }

    @lineBreakReg = /^(?:blockquote|pre|div|p)$/i;

    @effectNodeReg = /(?:[pubia]|h[1-6]|blockquote|[uo]l|li)/i;

    @strReg =
      whiteSpace: /(^\s+)|(\s+$)/g,
      mailTo: /^(?!mailto:|.+\/|.+#|.+\?)(.*@.*\..+)$/,
      http: /^(?!\w+?:\/\/|mailto:|\/|\.\/|\?|#)(.*)$/

  default_config: ()->
    ###
    buttons: [
        'blockquote', 'h2', 'h3', 'p', 'code', 'insertorderedlist', 'insertunorderedlist', 'inserthorizontalrule',
        'indent', 'outdent', 'bold', 'italic', 'underline', 'createlink'
      ]
    ###

    buttons: ['align-left', 'align-right', 'center']

  template: ()=>
    html = "<ul class='dante-menu-buttons'>"
    _.each @config.buttons, (item)->
      html += "<li class='dante-menu-button'><i class=\"dante-icon icon-#{item}\" data-action=\"#{item}\">#{item}</i></li>"
    html += "</ul>"
    html

  render: ()=>
    $(@el).html(@template())
    @show()

  handleClick: (ev)->
    element   = $(ev.currentTarget).find('.dante-icon')
    action    = element.data("action")
    input     = $(@el).find("input.dante-menu-input")
    utils.log("menu #{action} item clicked!")
    @savedSel = utils.saveSelection()
    @menuApply action

    return false

  effectNode: (el, returnAsNodeName) ->
    nodes = []
    el = el or @current_editor.$el[0]
    while el isnt @current_editor.$el[0]
      if el.nodeName.match(@effectNodeReg)
        nodes.push (if returnAsNodeName then el.nodeName.toLowerCase() else el)
      el = el.parentNode
    nodes

  menuApply: (action, value)=>
    classes_to_remove = @config.buttons.map (btn) => return "image-" + btn
    img = @selectedImage.find("img");
    if ["align-left", "align-right"].indexOf(action) > -1
      width = img.data("width")
      height = img.data("height")
      ratio = width / height
      MAX_WIDTH = 350;

      if width > MAX_WIDTH
        width = MAX_WIDTH;
        height = MAX_WIDTH / ratio;

      @selectedImage.css({width: width, height: height});
    else
      @selectedImage.css({width: "auto", height: "auto"});

    @selectedImage.removeClass(classes_to_remove.join(" ")).addClass("image-" + action);
    return false

  setupInsertedElement: (element)->
    n = @current_editor.addClassesToElement(element)
    @current_editor.setElementName(n)
    @current_editor.markAsSelected(n)

  displayHighlights: ()->
    #remove all active links
    $(@el).find(".active").removeClass("active")

    nodes = @effectNode(utils.getNode())
    utils.log(nodes)
    _.each nodes, (node)=>
      tag = node.nodeName.toLowerCase()

      @highlight(tag)

  highlight: (tag)->
    $(".icon-#{tag}").parent("li").addClass("active")

  show: (elem)->
    @selectedImage = elem
    $(@el).addClass("dante-menu--active")
    @displayHighlights()

  hide: ()->
    @selectedImage = null
    $(@el).removeClass("dante-menu--active")
