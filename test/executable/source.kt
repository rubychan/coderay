class Test {
    val text1: String = "abc \' def \u0000 \n \" hehe "
    val text2: List<Char> = listOf('a', '\n', '\'', '"', '\"')
    val numbers = listOf(0, 12, 1.0f, 1.0, 1L, 0x1f, -1, -12, -1.0f, -1.0, -1L)

    val template = "abc${1 + "b"}def"
    val template2 = "abc${1 + 'b'}def"
    val template3 = "abc $var def"

    val multiline = """ first line $var ${1 + 1}
        second line
        and quotes: ' " ''  ""  ok
        """

    val innerBraces = " before ${ if (true) { 1 } else { 2 } }"

    var v: Int = 0

    fun function(): ReturnType {
    }

    fun <T : Any> parametrizedFunction(): T = TODO()

    fun references() {
        super.references()
        this.references()
    }

    @Annotation
    class Annotated

    inner class Inner<in T, out E>

    object O

    companion object {
    }
}