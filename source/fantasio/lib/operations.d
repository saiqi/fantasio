module fantasio.lib.operations;

import std.range;

/**
 * Perform the equivalent operation of a SQL `LEFT OUTER JOIN`
 * Params:
 *   leftKeyFunc = the reference (left) range function
 *   rightKeyFunc = the other (right) range functio
 *   left = the reference range
 *   right = the other range
 *   fun = a function operating on the valid content of the result
 *
 * Returns:
 *   `Tuple!(ElementType!R1, "left", Nullable!(ElementType!R2), "right")`
 */
auto leftouterjoin(alias leftKeyFunc, alias rightKeyFunc, R1, R2)(R1 left, R2 right)
        if (isInputRange!R1 && isInputRange!R2)
{
    import std.typecons : Tuple, Nullable, nullable;
    import std.traits : arity;
    import std.functional : binaryFun;

    static struct LeftOuterJoinResult(alias leftKeyFunc, alias rightKeyFunc, R1, R2)
    {
    private:
        R1 left_;
        R2 right_;
        alias comp = binaryFun!"a < b";
        alias LeftOuterJoinItem = Tuple!(ElementType!R1, "left", Nullable!(ElementType!R2), "right");

        void adjustPosition()
        {
            if (left_.empty || right_.empty)
                return;

            if (comp(rightKeyFunc(right_.front), leftKeyFunc(left_.front)))
            {
                do
                {
                    right_.popFront();
                    if (right_.empty)
                        return;
                }
                while (comp(rightKeyFunc(right_.front), leftKeyFunc(left_.front)));
            }
        }

    public:
        this(R1 left, R2 right)
        {
            this.left_ = left;
            this.right_ = right;
            adjustPosition();
        }

        @property bool empty()
        {
            return left_.empty;
        }

        @property auto front()
        {
            assert(!empty);

            if (right_.empty)
                return LeftOuterJoinItem(this.left_.front, Nullable!(ElementType!R2).init);

            return rightKeyFunc(right_.front) == leftKeyFunc(left_.front)
                ? LeftOuterJoinItem(left_.front, right_.front.nullable) : LeftOuterJoinItem(left_.front, Nullable!(
                        ElementType!R2).init);

        }

        void popFront()
        {
            assert(!empty);
            left_.popFront();
            adjustPosition();
        }

        auto save()
        {
            auto retval = this;
            retval.left_ = left_.save;
            retval.right_ = right_.save;
            return retval;
        }
    }

    return LeftOuterJoinResult!(leftKeyFunc, rightKeyFunc, R1, R2)(left, right);
}
