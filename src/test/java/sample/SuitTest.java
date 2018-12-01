package sample;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import sample.junit.PriorityTest;


/**
 * Created by duongnapham on 8/26/15.
 */
@RunWith(Suite.class)
@Suite.SuiteClasses({
        PriorityTest.class,
})
public class SuitTest {
}
