class PostsController < ApplicationController
  before_filter :require_authentication, :except => [:index, :show, :archive, :articles, :media]
  
  def show
    if params[:permalink]
      @post = Post.find_by_permalink(params[:permalink])
    else
      @post = Post.find(params[:id])
    end
  end
  
  def edit
    @post = Post.find(params[:id])
    if request.post?
      @post.update_attributes(params[:post])
      @post.auto_tag! if @post.tag_list.blank?
    end
    render(:layout => 'dashboard')
  end
  
  def delete
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to(manage_articles_url)
  end
  
  def archive
    @posts = @stream.posts.find(:all, :include => [:service], :conditions => ["services.identifier = 'articles'"])
  end
  
  def new
    @post = Post.new(params[:post])
    if request.post?
      @post.is_draft = true
      @post.service = Service.find_or_create_by_identifier('articles')
      @post.stream = @stream
      @post.save
      @post.auto_tag! if @post.tag_list.blank?
      redirect_to(edit_post_url(:id => @post.id)) and return
    end
    render(:layout => 'dashboard')
  end
  
  def articles
    @articles = @stream.articles.find(:all, :limit => 10)
    respond_to do |format|
      format.rss
      format.atom
      format.html do
        require_authentication
        render(:layout => 'dashboard')
      end
    end
  end
  
  def index
    if params[:tag_name].blank?
      #
      @posts = Post.paginate(:all, :per_page => 20, :page => params[:page], :conditions => ["is_deleted IS false"], :order => 'published_at DESC')
      #@posts = @stream.posts.paginate(:all, :limit => 12)
    else
      @posts = Post.find_tagged_with(params[:tag_name], :conditions => 'is_draft IS FALSE AND is_deleted IS FALSE', :limit => 20)
    end
    respond_to(:html, :rss, :atom)
  end
  
  def manage
    @posts = Post.find(:all, :include => [:service], :conditions => ["services.identifier != 'articles'"], :order => 'posts.id DESC')
    render(:layout => 'dashboard')
  end
  
  def media
    @media_posts = Post.paginate(:all, 
                                 :per_page => 12, 
                                 :page => params[:page], 
                                 :include => [:medias],
                                 :conditions => ["is_deleted IS false AND medias.id IS NOT NULL"], 
                                 :order => 'posts.created_at DESC')
  end
  
end
