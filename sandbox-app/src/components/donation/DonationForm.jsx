import Input from '@mui/material/Input';
import { useNavigate } from 'react-router-dom';
import { useForm } from "react-hook-form";
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import './DonationForm.scss';

const DonationForm = ({ campaign }) => {
    const { register, handleSubmit, watch, formState: { errors } } = useForm();
    const onSubmit = data => console.log(data);

    const { name } = campaign || {};
    return (
        <div>
            <h3>{`New donation for: ${name}`}</h3>
            <Box
                component="form"
                sx={{ display: 'flex', alignItems: 'flex-start', flexDirection: 'column' }}
                noValidate
                autoComplete="off"
                onSubmit={handleSubmit(onSubmit)}>
                <TextField className="field" label="Donation amount" variant="filled" {...register("example")} />
                <TextField className="field" label="Description" variant="filled" {...register("exampleRequired", { required: true })} />
                {errors.exampleRequired && <span>This field is required</span>}
                <FormControl className="field" {...register("payment", { required: true })}>
                    <Select
                        labelId="demo-simple-select-label"
                        id="demo-simple-select"
                        value="credit_card"
                        label="Payment"
                    >
                        <MenuItem value={'credit_card'}>Credit Card</MenuItem>
                    </Select>
                </FormControl>
                <Input type="submit" />
            </Box>
        </div>
    );
}

export default DonationForm;
