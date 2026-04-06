import {Helmet} from 'react-helmet-async';

import {PastElectionsView} from "../sections/past-elections/view";
import {useParams} from "react-router-dom";


export default function PastElectionsPage() {
    const { year, electionType, election } = useParams()
    return (
        <>
            <Helmet>
                <title> Past Elections | Online Voting </title>
            </Helmet>

            <PastElectionsView year={year} electionType={electionType} election={election}/>
        </>
    );
}
