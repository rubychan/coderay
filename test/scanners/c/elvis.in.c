This?is+no:label;

// This is only one label:
label: switch (TYPE(v)) {
  case T_CLASS: case T_MODULE:
    rb_str_append(s, rb_inspect(v));
    break;
  default:
    rb_str_append(s, rb_any_to_s(v));
    break;
}
// These are two labels.
function(call);
label2: label3: a = b + c;

// Another label.
if (1) {
  label4: a = b + c;
}

// Not a label.
test(
  a?
  b:
  c
)