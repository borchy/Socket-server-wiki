class Form
  def self.create_page_form(page_name)
    form_page("Create the new page", page_name, "")
  end
  
  def self.edit_page_form(page_name, page_contents)
    form_page("Edit the current page", page_name, page_contents)
  end

  private
  
  def self.form_page(title, page_name, page_contents) 
    contents = <<-HTML
    #{title}
    <form action="#{page_name}" method="post">
      <textarea name="contents" cols=60 rows=30>#{page_contents}</textarea>
      <br>
      <input type="submit" value="Submit" />
    </form>
  HTML
  end
end
