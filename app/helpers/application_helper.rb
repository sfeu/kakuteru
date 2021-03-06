# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def sized_caption(caption, url, options = {})
    klass = nil
    if caption.size < 15
      klass = '_biggest'
    end
    if @post
      caption = content_tag(:h1, caption, options.merge(:class => 'entry-title'))
    else
      caption = link_to(content_tag(:span, caption, options.merge(:class => "entry-title caption caption#{klass}")), url, :class => 'caption')
    end
    caption
  end
  
  def read_url(params = {})
    permalink = nil
    if params[:id].is_a?(Post)
      permalink = params[:id].permalink
    end
    url = post_url(params)
    url += "-#{permalink}" unless permalink.blank?
    url
  end
  
  def attribution_for(post)
    type = post.type
    case type
      when 'video'
        unless post.medias.blank?
          url = post.medias.first.url
          link_to("view on #{Link.domain_for_url(url)}", url)
        end
      when 'photo'
        unless post.medias.blank?
          url = post.medias.first.url
          link_to("view on #{Link.domain_for_url(url)}", url)
        end
    end
  end
  
  def markup(post, field = :body)
    case post.type
      when 'article'
        case post.markup
          when 'textile'
            FilteredColumn::Processor.new('textile_filter', post.send(field)).filter
          when 'markdown'
            FilteredColumn::Processor.new('markdown_filter', post.send(field)).filter
          else
            post.send(field)
        end
      when 'message'
        markup_nanoformats(post)
    end
  end
  
  def thumbnail(post)
    #return image_tag('dodo.jpg')
    service = post.service
    if post.type == 'photo' || post.type == 'slide'
      image_tag(post.medias.first.thumbnail_url)
    elsif !service.profile_image_url.blank?
      image_tag(service.profile_image_url)
    else
      image_tag("#{post.type}.png")
    end
  end
  
  def markup_nanoformats(post)
    match = post.service.profile_url.to_s.match(/http:\/\/([^\/]+)\//)
    service_base_url = match[1]
    body = post.caption.dup
    
    # Link http://
    body.gsub!(/http:\/\/([^\s]+)/, "<a href=\"http://\\1\">\\1</a>")
    
    # Hashtag support
    hashtag_url = 'http://search.twitter.com/search?lang=all&q='
    body.gsub!(/\#([^\s,]+)/, "<a href=\"#{hashtag_url}\\1\">#\\1</a>")
    
    # @username support
    body.gsub!(/\@([^\s,]+)/, "<a href=\"#{service_base_url}/\\1\">@\\1</a>")
    
    body
  end
end
