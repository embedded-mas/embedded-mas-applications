/* Calculate the angle between (X1,Y1) and (X2,Y2) in radians */

package jason.stdlib;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.InternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;

public class angle extends DefaultInternalAction {

    @Override
    public int getMinArgs() {
        return 5;
    }

    @Override
    public int getMaxArgs() {
        return 5;
    }

    @Override
    public Object execute(
            TransitionSystem ts,
            Unifier un,
            Term[] args) throws Exception {


        // System.out.println("Executing internal action 'angle' with arguments: " + java.util.Arrays.toString(args));

        checkArguments(args);

        double x1 = ((NumberTerm) args[0]).solve();
        double y1 = ((NumberTerm) args[1]).solve();
        double x2 = ((NumberTerm) args[2]).solve();
        double y2 = ((NumberTerm) args[3]).solve();

        double dx = x2 - x1;
        double dy = y2 - y1;

        // Angle from (X2,Y2) to (X1,Y1), in radians.
        double angle = Math.atan2(dy, dx);

                // System.out.println("dx, dy: " + dx + ", " + dy);

        return un.unifies(
                args[4],
                ASSyntax.createNumber(angle)
        );
    }
}
