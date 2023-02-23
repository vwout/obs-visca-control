function lunit.assert_table_equal(expected, actual)
    lunit.assert_table(expected, "expected is not table")
    lunit.assert_table(actual, "actual is not table")

    lunit.assert_equal(#expected, #actual, "Table sizes not equal")
    for i = 1, #expected do
        lunit.assert_equal(expected[i], actual[i], "Mismatch at entry " .. i)
    end
end