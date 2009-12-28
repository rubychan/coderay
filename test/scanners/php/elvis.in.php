$this?$is+NO:$label;

// Two labels:
foo: switch (TYPE(v)) {
  case T_CLASS: case T_MODULE:
    rb_str_append(s, rb_inspect(v));
    break;
  default:
    bar:
    rb_str_append(s, rb_any_to_s(v));
    break;
}
// These are two more labels:
function(call);
label2: label3: a = b + c;

// Another label:
if (1) {
  label4: a = b + c;
}

// Not a label.
test(
  a?
  b:
  c
)