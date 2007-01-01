p "#{<<'END'.strip.reverse}\
First
END
Second"

p <<`one` ; p "#{<<two}"
1
one
2
two

this.should.be.plain

# from Rails
unless new_record?
  connection.delete <<-end_sql, "#{self.class.name} Destroy"
    DELETE FROM #{self.class.table_name}
    WHERE #{self.class.primary_key} = #{quoted_id}
  end_sql
end

p <<this
but it may break #{<<that}
code.
that
this
that.should.be.plain